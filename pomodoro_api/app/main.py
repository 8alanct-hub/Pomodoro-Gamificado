"""API de Pomodoro UTB (FastAPI + Supabase).

Correr:  uvicorn app.main:app --reload
Docs:    http://127.0.0.1:8000/docs
"""

import logging

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from .config import ajustes
from .routers import auth, configuracion, logros, mascota, materias, perfil, pesca, sesiones

app = FastAPI(
    title="Pomodoro API",
    version="1.0.0",
    description="Backend del Pomodoro gamificado: sesiones, racha, mascota, conchas y logros.",
)

_log = logging.getLogger("pomodoro_api")


# Se registra antes que CORS para que CORS quede por fuera: así un error 500
# también lleva sus cabeceras y el navegador muestra el mensaje en vez de
# "No se pudo conectar".
@app.middleware("http")
async def errores_inesperados(request: Request, call_next):
    try:
        return await call_next(request)
    except Exception:
        _log.exception("Error inesperado en %s %s", request.method, request.url.path)
        return JSONResponse(
            status_code=500,
            content={"detail": "El servidor tuvo un problema. Intenta de nuevo."},
        )


app.add_middleware(
    CORSMiddleware,
    allow_origins=ajustes().cors_origenes,
    allow_methods=["*"],
    allow_headers=["*"],
)

for r in (auth, perfil, configuracion, materias, sesiones, mascota, pesca, logros):
    app.include_router(r.router)


@app.get("/salud", tags=["Salud"])
def salud() -> dict:
    return {"estado": "ok"}
