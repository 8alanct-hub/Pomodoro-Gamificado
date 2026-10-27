"""Minijuego Pesca rápida (RF-017): cuesta 1 concha y da felicidad."""

from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, status

from .. import datos, reglas
from ..esquemas import Mascota, PartidaFin, PartidaIniciada
from ..seguridad import Usuario, usuario_actual
from ..supabase_cliente import db

router = APIRouter(prefix="/pesca", tags=["Pesca rápida"])


@router.post("/partidas", response_model=PartidaIniciada, status_code=status.HTTP_201_CREATED)
def iniciar(usuario: Usuario = Depends(usuario_actual)) -> PartidaIniciada:
    if datos.leer_mascota(usuario.id).estado == "huevo":
        raise HTTPException(status.HTTP_409_CONFLICT, "Tu mascota aún no ha nacido.")
    conchas = datos.saldo_conchas(usuario.id)
    if conchas < 1:
        raise HTTPException(
            status.HTTP_409_CONFLICT, "Completa un pomodoro de 25 minutos para ganar una concha."
        )
    p = db().table("partidas_pesca").insert({"usuario_id": usuario.id}).execute().data[0]
    db().table("movimientos_conchas").insert(
        {"usuario_id": usuario.id, "partida_id": p["id"], "cantidad": -1, "motivo": "entrada_pesca"}
    ).execute()
    return PartidaIniciada(partida_id=p["id"], conchas=conchas - 1)


@router.post("/partidas/{partida_id}/finalizar", response_model=Mascota)
def finalizar(
    partida_id: str, fin: PartidaFin, usuario: Usuario = Depends(usuario_actual)
) -> Mascota:
    r = (
        db()
        .table("partidas_pesca")
        .select("finalizada_en")
        .eq("id", partida_id)
        .eq("usuario_id", usuario.id)
        .maybe_single()
        .execute()
    )
    p = r.data if r else None
    if not p:
        raise datos.no_encontrado("la partida")
    if p["finalizada_en"]:
        raise HTTPException(status.HTTP_409_CONFLICT, "Esta partida ya se había guardado.")

    felicidad = reglas.felicidad_por_partida(fin.puntos)
    db().table("partidas_pesca").update(
        {
            "finalizada_en": datetime.now().astimezone().isoformat(),
            "motivo_fin": fin.motivo_fin,
            "duracion_segundos": fin.duracion_segundos,
            "puntos": fin.puntos,
            "peces": fin.peces,
            "felicidad_ganada": felicidad,
        }
    ).eq("id", partida_id).execute()
    datos.sumar_felicidad(usuario.id, felicidad)
    return datos.leer_mascota(usuario.id)
