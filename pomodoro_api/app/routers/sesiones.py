"""Sesiones de estudio y recompensas (RF-005, RF-010, RF-011, RF-016).

Flujo desde Flutter:
1. Al empezar el pomodoro → POST /sesiones (el servidor anota la hora de inicio).
2. Al terminar, saltar o salir → POST /sesiones/{id}/finalizar con los segundos
   estudiados. El servidor da las conchas, suma la racha y devuelve la mascota.
"""

from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, Query, status

from .. import datos, reglas
from ..config import ajustes
from ..esquemas import ResultadoSesion, SesionFin, SesionHistorial, SesionIniciada, SesionNueva
from ..seguridad import Usuario, usuario_actual
from ..supabase_cliente import db

router = APIRouter(prefix="/sesiones", tags=["Sesiones de estudio"])

# Margen por la latencia entre el teléfono y el servidor.
_TOLERANCIA = timedelta(seconds=30)


def _historial(f: dict) -> SesionHistorial:
    return SesionHistorial(
        id=f["id"],
        materia_id=f["materia_id"],
        iniciada_en=f["iniciada_en"],
        minutos_enfoque=f["segundos_estudiados"] // 60,
        completada=f["estado"] == "completada",
    )


@router.post("", response_model=SesionIniciada, status_code=status.HTTP_201_CREATED)
def iniciar(datos_sesion: SesionNueva, usuario: Usuario = Depends(usuario_actual)) -> SesionIniciada:
    existe = (
        db()
        .table("materias")
        .select("id")
        .eq("id", datos_sesion.materia_id)
        .eq("usuario_id", usuario.id)
        .execute()
        .data
    )
    if not existe:
        raise datos.no_encontrado("la materia")
    # Una sesión anterior que quedó abierta (la app se cerró) se da por terminada.
    db().table("sesiones_estudio").update(
        {"estado": "terminada_antes", "finalizada_en": datetime.now().astimezone().isoformat()}
    ).eq("usuario_id", usuario.id).eq("estado", "en_curso").execute()

    f = (
        db()
        .table("sesiones_estudio")
        .insert(
            {
                "usuario_id": usuario.id,
                "materia_id": datos_sesion.materia_id,
                "minutos_planeados": datos_sesion.minutos_planeados,
            }
        )
        .execute()
        .data[0]
    )
    return SesionIniciada(id=f["id"], iniciada_en=f["iniciada_en"])


@router.post("/{sesion_id}/finalizar", response_model=ResultadoSesion)
def finalizar(
    sesion_id: str, fin: SesionFin, usuario: Usuario = Depends(usuario_actual)
) -> ResultadoSesion:
    r = (
        db()
        .table("sesiones_estudio")
        .select("*")
        .eq("id", sesion_id)
        .eq("usuario_id", usuario.id)
        .maybe_single()
        .execute()
    )
    s = r.data if r else None
    if not s:
        raise datos.no_encontrado("la sesión")
    if s["estado"] != "en_curso":
        raise HTTPException(status.HTTP_409_CONFLICT, "Esta sesión ya se había finalizado.")

    # No se pueden reportar más segundos de los planeados ni de los que pasaron.
    segundos = min(fin.segundos_estudiados, s["minutos_planeados"] * 60)
    if not ajustes().modo_desarrollo:
        transcurrido = datetime.now().astimezone() - datetime.fromisoformat(s["iniciada_en"])
        segundos = min(segundos, int((transcurrido + _TOLERANCIA).total_seconds()))
    segundos = max(0, segundos)

    f = (
        db()
        .table("sesiones_estudio")
        .update(
            {
                "estado": fin.estado,
                "segundos_estudiados": segundos,
                "finalizada_en": datetime.now().astimezone().isoformat(),
            }
        )
        .eq("id", sesion_id)
        .execute()
        .data[0]
    )

    hoy = datos.hoy_local(usuario.id)
    conchas = reglas.conchas_para(segundos)
    _sumar_actividad(usuario.id, hoy.isoformat(), segundos, 1 if fin.estado == "completada" else 0)

    racha_nueva = nacio = False
    aviso = None
    if conchas > 0:
        db().table("movimientos_conchas").insert(
            {
                "usuario_id": usuario.id,
                "sesion_id": sesion_id,
                "cantidad": conchas,
                "motivo": "recompensa_estudio",
            }
        ).execute()
        antes = datos.leer_racha(usuario.id)
        res = reglas.registrar_bloque(antes, hoy)
        datos.guardar_racha(usuario.id, antes, res.estado)
        racha_nueva, nacio, aviso = res.racha_nueva, res.nacio, res.aviso

    return ResultadoSesion(
        sesion=_historial(f),
        conchas_ganadas=conchas,
        racha_nueva=racha_nueva,
        nacio=nacio,
        mascota=datos.leer_mascota(usuario.id, aviso),
    )


def _sumar_actividad(usuario_id: str, fecha: str, segundos: int, pomodoros: int) -> None:
    tabla = db().table("actividad_diaria")
    r = (
        tabla.select("segundos_enfoque, pomodoros_completados")
        .eq("usuario_id", usuario_id)
        .eq("fecha_local", fecha)
        .maybe_single()
        .execute()
    )
    previo = (r.data if r else None) or {"segundos_enfoque": 0, "pomodoros_completados": 0}
    tabla.upsert(
        {
            "usuario_id": usuario_id,
            "fecha_local": fecha,
            "segundos_enfoque": previo["segundos_enfoque"] + segundos,
            "pomodoros_completados": previo["pomodoros_completados"] + pomodoros,
        }
    ).execute()


@router.get("", response_model=list[SesionHistorial])
def historial(
    desde: datetime = Query(description="Incluido, ISO 8601 con zona horaria"),
    hasta: datetime = Query(description="Excluido, ISO 8601 con zona horaria"),
    usuario: Usuario = Depends(usuario_actual),
) -> list[SesionHistorial]:
    """Sesiones terminadas entre dos fechas, de la más reciente a la más antigua."""
    filas = (
        db()
        .table("sesiones_estudio")
        .select("id, materia_id, iniciada_en, segundos_estudiados, estado")
        .eq("usuario_id", usuario.id)
        .neq("estado", "en_curso")
        .gte("iniciada_en", desde.isoformat())
        .lt("iniciada_en", hasta.isoformat())
        .order("iniciada_en", desc=True)
        .execute()
        .data
        or []
    )
    return [_historial(f) for f in filas]
