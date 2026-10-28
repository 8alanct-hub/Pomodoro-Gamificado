"""Configuración leída del archivo .env (ver .env.example)."""

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Ajustes(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    # Supabase → Project Settings → API.
    supabase_url: str
    # Clave pública (publishable / anon): solo para login y verificar tokens.
    supabase_publishable_key: str
    # Clave secreta (secret / service_role): SOLO en el servidor, nunca en Flutter.
    supabase_secret_key: str

    # Dominio permitido para registrarse (RF-001).
    dominio_correo: str = "utb.edu.co"

    # En desarrollo la app Flutter corre el reloj 60 veces más rápido, así que
    # no se puede exigir que el tiempo estudiado sea real.
    modo_desarrollo: bool = False

    # Orígenes permitidos para CORS (Flutter web en desarrollo).
    cors_origenes: list[str] = ["*"]

    # IA de la mascota (Gemini). Sin clave, la mascota usa mensajes fijos.
    # Clave en https://aistudio.google.com/apikey
    gemini_api_key: str = ""
    gemini_modelo: str = "gemini-3.5-flash-lite"


@lru_cache
def ajustes() -> Ajustes:
    return Ajustes()
