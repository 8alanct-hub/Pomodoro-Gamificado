"""Mascota, racha, panes y conchas (RF-010, RF-014, RF-015)."""

from datetime import datetime, time

from fastapi import APIRouter, Depends, HTTPException, status

from .. import datos, ia, reglas
from ..esquemas import Mascota, MensajeMascota, NombreMascota
from ..logros import inicio_semana
from ..seguridad import Usuario, usuario_actual
from ..supabase_cliente import db

router = APIRouter(prefix="/mascota", tags=["Mascota"])


@router.get("", response_model=Mascota)
def obtener(usuario: Usuario = Depends(usuario_actual)) -> Mascota:
    """Llamar al abrir la app: revisa los días sin estudiar (gasta panes o
    reinicia la racha) y devuelve el estado. `aviso` dice qué pasó."""
    aviso = datos.revisar_racha(usuario.id)
    return datos.leer_mascota(usuario.id, aviso)


@router.get("/mensaje", response_model=MensajeMascota)
def mensaje(usuario: Usuario = Depends(usuario_actual)) -> MensajeMascota:
    """Lo que dice la mascota en su globo, generado con IA según los datos
    del estudiante (racha, felicidad, estudio de hoy y materias atrasadas)."""
    aviso = datos.revisar_racha(usuario.id)
    m = datos.leer_mascota(usuario.id)
    ahora = datos.ahora_local(usuario.id)
    contexto = ia.Contexto(
        nombre_mascota=m.nombre or "tu mascota",
        nombre_estudiante=_primer_nombre(usuario.id),
        felicidad=m.felicidad,
        racha_dias=m.racha_dias,
        panes=m.panes,
        conchas=m.conchas,
        minutos_hoy=_minutos_hoy(usuario.id, ahora.date().isoformat()),
        momento_del_dia="mañana" if ahora.hour < 12 else "tarde" if ahora.hour < 19 else "noche",
        materias_atrasadas=_materias_atrasadas(usuario.id, ahora),
        aviso=aviso,
    )
    if m.estado == "huevo":
        return MensajeMascota(mensaje="Completa un pomodoro de 25 min y naceré.", fuente="respaldo")
    texto, fuente = ia.mensaje_mascota(usuario.id, contexto, ahora.date().isoformat())
    return MensajeMascota(mensaje=texto, fuente=fuente)


def _primer_nombre(usuario_id: str) -> str:
    r = db().table("perfiles").select("nombre").eq("id", usuario_id).maybe_single().execute()
    nombre = ((r.data if r else None) or {}).get("nombre") or ""
    return nombre.split(" ")[0]


def _minutos_hoy(usuario_id: str, fecha: str) -> int:
    r = (
        db()
        .table("actividad_diaria")
        .select("segundos_enfoque")
        .eq("usuario_id", usuario_id)
        .eq("fecha_local", fecha)
        .maybe_single()
        .execute()
    )
    return (((r.data if r else None) or {}).get("segundos_enfoque") or 0) // 60


def _materias_atrasadas(usuario_id: str, ahora: datetime) -> tuple[str, ...]:
    """Materias por debajo de lo esperado a esta altura de la semana (RF-012),
    de la más atrasada a la menos; como máximo dos."""
    lunes = inicio_semana(ahora)
    desde = datetime.combine(lunes, time.min, ahora.tzinfo)
    materias = (
        db()
        .table("materias")
        .select("id, nombre, horas_totales, semanas_semestre")
        .eq("usuario_id", usuario_id)
        .execute()
        .data
        or []
    )
    sesiones = (
        db()
        .table("sesiones_estudio")
        .select("materia_id, segundos_estudiados")
        .eq("usuario_id", usuario_id)
        .neq("estado", "en_curso")
        .gte("iniciada_en", desde.isoformat())
        .execute()
        .data
        or []
    )
    minutos: dict[str, int] = {}
    for s in sesiones:
        minutos[s["materia_id"]] = minutos.get(s["materia_id"], 0) + s["segundos_estudiados"] // 60
    dias_transcurridos = ahora.weekday() + 1
    faltas = []
    for x in materias:
        meta_semana_min = float(x["horas_totales"]) / x["semanas_semestre"] * 60
        esperado = meta_semana_min * dias_transcurridos / 7
        falta = esperado - minutos.get(x["id"], 0)
        if falta >= 15:  # Menos de un cuarto de hora no cuenta como atraso.
            faltas.append((falta, x["nombre"]))
    faltas.sort(reverse=True)
    return tuple(nombre for _, nombre in faltas[:2])


@router.post("/acariciar", response_model=Mascota)
def acariciar(usuario: Usuario = Depends(usuario_actual)) -> Mascota:
    m = datos.leer_mascota(usuario.id)
    if m.estado == "huevo":
        raise HTTPException(status.HTTP_409_CONFLICT, "Tu mascota aún no ha nacido.")
    datos.sumar_felicidad(usuario.id, reglas.FELICIDAD_CARICIA)
    return datos.leer_mascota(usuario.id)


@router.put("/nombre", response_model=Mascota)
def poner_nombre(cuerpo: NombreMascota, usuario: Usuario = Depends(usuario_actual)) -> Mascota:
    """Nombre obligatorio al nacer; también sirve para cambiarlo después."""
    try:
        nombre = reglas.limpiar_nombre(cuerpo.nombre)
    except ValueError as e:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, str(e))
    if datos.leer_mascota(usuario.id).estado == "huevo":
        raise HTTPException(status.HTTP_409_CONFLICT, "Tu mascota aún no ha nacido.")
    db().table("mascotas").update(
        {"nombre": nombre, "actualizada_en": datetime.now().astimezone().isoformat()}
    ).eq("usuario_id", usuario.id).execute()
    return datos.leer_mascota(usuario.id)
