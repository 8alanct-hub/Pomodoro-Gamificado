"""Insignias (RF-009)."""

from datetime import datetime

from fastapi import APIRouter, Depends

from .. import datos
from ..esquemas import Logro
from ..logros import MateriaLogro, SesionLogro, calcular_logros
from ..seguridad import Usuario, usuario_actual
from ..supabase_cliente import db

router = APIRouter(prefix="/logros", tags=["Logros"])


@router.get("", response_model=list[Logro])
def listar(usuario: Usuario = Depends(usuario_actual)) -> list[dict]:
    zona = datos.zona(usuario.id)
    sesiones = (
        db()
        .table("sesiones_estudio")
        .select("materia_id, iniciada_en, segundos_estudiados")
        .eq("usuario_id", usuario.id)
        .neq("estado", "en_curso")
        .execute()
        .data
        or []
    )
    materias = (
        db()
        .table("materias")
        .select("horas_totales, semanas_semestre")
        .eq("usuario_id", usuario.id)
        .execute()
        .data
        or []
    )
    m = datos.leer_mascota(usuario.id)
    return calcular_logros(
        sesiones=[
            SesionLogro(
                inicio=datetime.fromisoformat(s["iniciada_en"]).astimezone(zona),
                materia_id=s["materia_id"],
                segundos=s["segundos_estudiados"],
            )
            for s in sesiones
        ],
        materias=[MateriaLogro(float(x["horas_totales"]), x["semanas_semestre"]) for x in materias],
        racha_actual=m.racha_dias,
        mejor_racha=m.mejor_racha,
        peces_totales=m.peces_totales,
        ahora=datetime.now(zona),
    )
