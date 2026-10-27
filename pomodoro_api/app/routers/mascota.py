"""Mascota, racha, panes y conchas (RF-010, RF-014, RF-015)."""

from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, status

from .. import datos, reglas
from ..esquemas import Mascota, NombreMascota
from ..seguridad import Usuario, usuario_actual
from ..supabase_cliente import db

router = APIRouter(prefix="/mascota", tags=["Mascota"])


@router.get("", response_model=Mascota)
def obtener(usuario: Usuario = Depends(usuario_actual)) -> Mascota:
    """Llamar al abrir la app: revisa los días sin estudiar (gasta panes o
    reinicia la racha) y devuelve el estado. `aviso` dice qué pasó."""
    aviso = datos.revisar_racha(usuario.id)
    return datos.leer_mascota(usuario.id, aviso)


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
