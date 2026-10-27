"""Duraciones del pomodoro (RF-006)."""

from datetime import datetime

from fastapi import APIRouter, Depends

from ..esquemas import Configuracion
from ..seguridad import Usuario, usuario_actual
from ..supabase_cliente import db

router = APIRouter(prefix="/configuracion", tags=["Configuración"])

_COLUMNAS = "minutos_enfoque, minutos_descanso_corto, minutos_descanso_largo, pomodoros_por_ciclo"


@router.get("", response_model=Configuracion)
def obtener(usuario: Usuario = Depends(usuario_actual)) -> Configuracion:
    r = (
        db()
        .table("configuracion_pomodoro")
        .select(_COLUMNAS)
        .eq("usuario_id", usuario.id)
        .maybe_single()
        .execute()
    )
    f = r.data if r else None
    if not f:
        return Configuracion()
    return Configuracion(
        enfoque_min=f["minutos_enfoque"],
        descanso_corto_min=f["minutos_descanso_corto"],
        descanso_largo_min=f["minutos_descanso_largo"],
        pomodoros_por_ciclo=f["pomodoros_por_ciclo"],
    )


@router.put("", response_model=Configuracion)
def guardar(c: Configuracion, usuario: Usuario = Depends(usuario_actual)) -> Configuracion:
    """Valores fuera de rango se rechazan con 422 y se conserva la configuración anterior."""
    db().table("configuracion_pomodoro").upsert(
        {
            "usuario_id": usuario.id,
            "minutos_enfoque": c.enfoque_min,
            "minutos_descanso_corto": c.descanso_corto_min,
            "minutos_descanso_largo": c.descanso_largo_min,
            "pomodoros_por_ciclo": c.pomodoros_por_ciclo,
            "actualizada_en": datetime.now().astimezone().isoformat(),
        }
    ).execute()
    return c
