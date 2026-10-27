"""Lecturas y escrituras compartidas entre rutas (siempre filtradas por usuario)."""

from datetime import date, datetime
from zoneinfo import ZoneInfo

from fastapi import HTTPException, status

from . import reglas
from .esquemas import Mascota
from .supabase_cliente import db

ZONA_POR_DEFECTO = "America/Bogota"


def zona(usuario_id: str) -> ZoneInfo:
    r = db().table("perfiles").select("zona_horaria").eq("id", usuario_id).maybe_single().execute()
    nombre = (r.data or {}).get("zona_horaria") if r else None
    try:
        return ZoneInfo(nombre or ZONA_POR_DEFECTO)
    except Exception:
        return ZoneInfo(ZONA_POR_DEFECTO)


def ahora_local(usuario_id: str) -> datetime:
    return datetime.now(zona(usuario_id))


def hoy_local(usuario_id: str) -> date:
    return ahora_local(usuario_id).date()


def no_encontrado(que: str) -> HTTPException:
    return HTTPException(status.HTTP_404_NOT_FOUND, f"No se encontró {que}.")


# ---------- Racha y mascota ----------


def _fila(tabla: str, usuario_id: str, columnas: str = "*") -> dict:
    r = db().table(tabla).select(columnas).eq("usuario_id", usuario_id).maybe_single().execute()
    if r is None or not r.data:
        # El trigger crear_perfil_y_configuracion crea estas filas al registrarse.
        raise no_encontrado(f"el registro de {tabla} del usuario")
    return r.data


def leer_racha(usuario_id: str) -> reglas.EstadoRacha:
    racha = _fila("rachas_estudio", usuario_id)
    mascota = _fila("mascotas", usuario_id, "estado")
    ultimo = racha.get("ultimo_dia_estudiado")
    return reglas.EstadoRacha(
        racha_actual=racha["racha_actual"],
        mejor_racha=racha["mejor_racha"],
        panes=racha["panes_disponibles"],
        ultimo_dia=date.fromisoformat(ultimo) if ultimo else None,
        es_huevo=mascota["estado"] == "huevo",
    )


def guardar_racha(usuario_id: str, antes: reglas.EstadoRacha, e: reglas.EstadoRacha) -> None:
    if e == antes:
        return
    db().table("rachas_estudio").update(
        {
            "racha_actual": e.racha_actual,
            "mejor_racha": e.mejor_racha,
            "panes_disponibles": e.panes,
            "ultimo_dia_estudiado": e.ultimo_dia.isoformat() if e.ultimo_dia else None,
        }
    ).eq("usuario_id", usuario_id).execute()
    if e.es_huevo != antes.es_huevo:
        cambios = (
            {"estado": "huevo", "eclosionada_en": None, "felicidad": 50}
            if e.es_huevo
            else {"estado": "activa", "eclosionada_en": datetime.now().astimezone().isoformat()}
        )
        cambios["actualizada_en"] = datetime.now().astimezone().isoformat()
        db().table("mascotas").update(cambios).eq("usuario_id", usuario_id).execute()


def revisar_racha(usuario_id: str) -> str | None:
    """Gasta panes o reinicia la racha por los días sin estudiar (al abrir la app)."""
    antes = leer_racha(usuario_id)
    nuevo, aviso = reglas.revisar_dias_sin_estudiar(antes, hoy_local(usuario_id))
    guardar_racha(usuario_id, antes, nuevo)
    return aviso


def saldo_conchas(usuario_id: str) -> int:
    r = db().table("movimientos_conchas").select("cantidad").eq("usuario_id", usuario_id).execute()
    return sum(f["cantidad"] for f in r.data or [])


def leer_mascota(usuario_id: str, aviso: str | None = None) -> Mascota:
    racha = _fila("rachas_estudio", usuario_id)
    m = _fila("mascotas", usuario_id)
    partidas = (
        db()
        .table("partidas_pesca")
        .select("puntos, peces")
        .eq("usuario_id", usuario_id)
        .not_.is_("finalizada_en", "null")
        .execute()
        .data
        or []
    )
    return Mascota(
        estado="huevo" if m["estado"] == "huevo" else "nacida",
        nombre=m.get("nombre"),
        felicidad=m["felicidad"],
        racha_dias=racha["racha_actual"],
        mejor_racha=racha["mejor_racha"],
        panes=racha["panes_disponibles"],
        conchas=saldo_conchas(usuario_id),
        record_pesca=max((p["puntos"] for p in partidas), default=0),
        peces_totales=sum(p.get("peces") or 0 for p in partidas),
        aviso=aviso,
    )


def sumar_felicidad(usuario_id: str, cantidad: int) -> None:
    actual = _fila("mascotas", usuario_id, "felicidad")["felicidad"]
    db().table("mascotas").update(
        {
            "felicidad": max(0, min(100, actual + cantidad)),
            "actualizada_en": datetime.now().astimezone().isoformat(),
        }
    ).eq("usuario_id", usuario_id).execute()
