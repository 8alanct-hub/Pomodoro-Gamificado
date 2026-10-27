"""Datos de la cuenta (pantalla Perfil)."""

from fastapi import APIRouter, Depends

from ..esquemas import Estudiante, PerfilCambios
from ..seguridad import Usuario, usuario_actual
from ..supabase_cliente import db
from .auth import leer_estudiante

router = APIRouter(prefix="/perfil", tags=["Perfil"])


@router.get("", response_model=Estudiante)
def obtener(usuario: Usuario = Depends(usuario_actual)) -> Estudiante:
    return leer_estudiante(usuario.id, usuario.correo)


@router.patch("", response_model=Estudiante)
def actualizar(cambios: PerfilCambios, usuario: Usuario = Depends(usuario_actual)) -> Estudiante:
    """Cambia nombre y programa. El correo no se puede cambiar."""
    db().table("perfiles").update(
        {"nombre": cambios.nombre.strip(), "programa_academico": cambios.programa.strip()}
    ).eq("id", usuario.id).execute()
    return leer_estudiante(usuario.id, usuario.correo)
