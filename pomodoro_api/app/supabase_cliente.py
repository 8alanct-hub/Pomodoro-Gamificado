"""Clientes de Supabase.

- `db()`: usa la clave secreta. Salta las políticas RLS, así que TODAS las
  consultas deben filtrar por `usuario_id` del token verificado.
  Nunca se inicia sesión con este cliente (cambiaría su token).
- `cliente_auth()`: cliente nuevo con la clave pública para login, registro
  y refrescar sesión; se crea uno por petición para no mezclar sesiones.
"""

from functools import lru_cache

from supabase import Client, create_client

from .config import ajustes


@lru_cache
def db() -> Client:
    a = ajustes()
    return create_client(a.supabase_url, a.supabase_secret_key)


def cliente_auth() -> Client:
    a = ajustes()
    return create_client(a.supabase_url, a.supabase_publishable_key)
