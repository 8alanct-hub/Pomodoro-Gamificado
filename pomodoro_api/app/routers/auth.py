"""Registro, inicio y cierre de sesión (RF-001, RF-002)."""

from fastapi import APIRouter, Depends, HTTPException, status

from ..config import ajustes
from ..esquemas import Estudiante, Login, Refrescar, Registro, Sesion
from ..seguridad import Usuario, usuario_actual
from ..supabase_cliente import cliente_auth, db

router = APIRouter(prefix="/auth", tags=["Autenticación"])


def leer_estudiante(usuario_id: str, correo: str) -> Estudiante:
    r = (
        db()
        .table("perfiles")
        .select("nombre, programa_academico")
        .eq("id", usuario_id)
        .maybe_single()
        .execute()
    )
    p = (r.data if r else None) or {}
    return Estudiante(
        id=usuario_id,
        nombre=p.get("nombre") or "",
        correo=correo,
        programa=p.get("programa_academico") or "",
    )


def _sesion(respuesta) -> Sesion:
    s, u = respuesta.session, respuesta.user
    if s is None or u is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "No se pudo iniciar sesión.")
    return Sesion(
        access_token=s.access_token,
        refresh_token=s.refresh_token,
        expira_en=s.expires_in or 3600,
        estudiante=leer_estudiante(u.id, u.email or ""),
    )


@router.post("/registro", response_model=Sesion, status_code=status.HTTP_201_CREATED)
def registrar(datos: Registro) -> Sesion:
    correo = datos.correo.lower()
    dominio = ajustes().dominio_correo
    if not correo.endswith("@" + dominio):
        raise HTTPException(
            status.HTTP_422_UNPROCESSABLE_ENTITY, f"Usa tu correo institucional (@{dominio})."
        )
    try:
        # Se crea ya confirmado para no depender del correo de verificación en el MVP.
        creado = db().auth.admin.create_user(
            {
                "email": correo,
                "password": datos.contrasena,
                "email_confirm": True,
                "user_metadata": {"nombre": datos.nombre.strip()},
            }
        )
    except Exception as e:
        texto = str(e).lower()
        if "already" in texto or "registered" in texto or "exists" in texto:
            raise HTTPException(status.HTTP_409_CONFLICT, "Ese correo ya tiene una cuenta.")
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "No se pudo crear la cuenta.")

    try:
        # El trigger ya creó el perfil con el nombre; falta el programa.
        db().table("perfiles").update({"programa_academico": datos.programa.strip()}).eq(
            "id", creado.user.id
        ).execute()
        return _sesion(
            cliente_auth().auth.sign_in_with_password({"email": correo, "password": datos.contrasena})
        )
    except Exception:
        # Si algo falla después de crear el usuario, se borra para que el
        # estudiante pueda intentar de nuevo con el mismo correo.
        try:
            db().auth.admin.delete_user(creado.user.id)
        except Exception:
            pass
        raise


@router.post("/login", response_model=Sesion)
def login(datos: Login) -> Sesion:
    try:
        r = cliente_auth().auth.sign_in_with_password(
            {"email": datos.correo.lower(), "password": datos.contrasena}
        )
    except Exception:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Correo o contraseña incorrectos.")
    return _sesion(r)


@router.post("/refrescar", response_model=Sesion)
def refrescar(datos: Refrescar) -> Sesion:
    """Pide un access_token nuevo cuando el anterior vence (cada hora)."""
    try:
        r = cliente_auth().auth.refresh_session(datos.refresh_token)
    except Exception:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "La sesión venció; inicia sesión de nuevo.")
    return _sesion(r)


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
def logout(usuario: Usuario = Depends(usuario_actual)) -> None:
    try:
        db().auth.admin.sign_out(usuario.token)
    except Exception:
        pass  # Si ya estaba vencida, igual se considera cerrada.
