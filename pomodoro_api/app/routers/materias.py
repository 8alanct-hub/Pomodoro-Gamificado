"""Materias y minutos estudiados (RF-003, RF-004, RF-012)."""

from fastapi import APIRouter, Depends, status

from ..esquemas import Materia, MateriaNueva
from ..seguridad import Usuario, usuario_actual
from ..supabase_cliente import db

router = APIRouter(prefix="/materias", tags=["Materias"])


def _minutos_por_materia(usuario_id: str) -> dict[str, int]:
    filas = (
        db()
        .table("sesiones_estudio")
        .select("materia_id, segundos_estudiados")
        .eq("usuario_id", usuario_id)
        .neq("estado", "en_curso")
        .execute()
        .data
        or []
    )
    segundos: dict[str, int] = {}
    for f in filas:
        segundos[f["materia_id"]] = segundos.get(f["materia_id"], 0) + f["segundos_estudiados"]
    return {k: v // 60 for k, v in segundos.items()}


def _materia(f: dict, minutos: dict[str, int]) -> Materia:
    return Materia(
        id=f["id"],
        nombre=f["nombre"],
        horas_totales=float(f["horas_totales"]),
        semanas_semestre=f["semanas_semestre"],
        minutos_estudiados=minutos.get(f["id"], 0),
    )


@router.get("", response_model=list[Materia])
def listar(usuario: Usuario = Depends(usuario_actual)) -> list[Materia]:
    filas = (
        db()
        .table("materias")
        .select("id, nombre, horas_totales, semanas_semestre")
        .eq("usuario_id", usuario.id)
        .order("creada_en")
        .execute()
        .data
        or []
    )
    minutos = _minutos_por_materia(usuario.id)
    return [_materia(f, minutos) for f in filas]


@router.post("", response_model=Materia, status_code=status.HTTP_201_CREATED)
def agregar(datos: MateriaNueva, usuario: Usuario = Depends(usuario_actual)) -> Materia:
    f = (
        db()
        .table("materias")
        .insert(
            {
                "usuario_id": usuario.id,
                "nombre": datos.nombre.strip(),
                "horas_totales": datos.horas_totales,
                "semanas_semestre": datos.semanas_semestre,
            }
        )
        .execute()
        .data[0]
    )
    return _materia(f, {})
