"""Usuario autenticado a partir del token `Authorization: Bearer <access_token>`."""

from dataclasses import dataclass

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from .supabase_cliente import db

_bearer = HTTPBearer(auto_error=False)


@dataclass(frozen=True)
class Usuario:
    id: str
    correo: str
    token: str


def usuario_actual(
    cred: HTTPAuthorizationCredentials | None = Depends(_bearer),
) -> Usuario:
    if cred is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Falta el token de sesión.")
    try:
        # Supabase valida firma y vencimiento del token.
        r = db().auth.get_user(cred.credentials)
    except Exception:
        r = None
    if r is None or r.user is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Sesión vencida o inválida.")
    return Usuario(id=r.user.id, correo=r.user.email or "", token=cred.credentials)
