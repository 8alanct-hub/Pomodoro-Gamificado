"""Cálculo de las 12 insignias (RF-009), igual que LogroRepositoryLocal en Flutter.

Las insignias se calculan a partir de las sesiones, las materias y la mascota,
así que no hace falta guardar el avance: siempre está al día.
"""

import math
from dataclasses import dataclass
from datetime import date, datetime, timedelta

from .reglas import conchas_para, SEGUNDOS_POR_BLOQUE


@dataclass(frozen=True)
class SesionLogro:
    inicio: datetime  # en la hora local del estudiante
    materia_id: str
    segundos: int


@dataclass(frozen=True)
class MateriaLogro:
    horas_totales: float
    semanas_semestre: int

    @property
    def meta_semanal_horas(self) -> float:
        return self.horas_totales / self.semanas_semestre


def inicio_semana(d: datetime | date) -> date:
    dia = d.date() if isinstance(d, datetime) else d
    return dia - timedelta(days=dia.weekday())  # lunes


def _hora(d: datetime) -> str:
    h = 12 if d.hour % 12 == 0 else d.hour % 12
    return f"{h}:{d.minute:02d} {'a. m.' if d.hour < 12 else 'p. m.'}"


def calcular_logros(
    sesiones: list[SesionLogro],
    materias: list[MateriaLogro],
    racha_actual: int,
    mejor_racha: int,
    peces_totales: int,
    ahora: datetime,
) -> list[dict]:
    completas = [s for s in sesiones if s.segundos >= SEGUNDOS_POR_BLOQUE]
    pomodoros = sum(conchas_para(s.segundos) for s in completas)
    horas_totales = sum(s.segundos // 60 for s in sesiones) / 60

    semana = inicio_semana(ahora)
    de_la_semana = [s for s in sesiones if s.inicio.date() >= semana]
    pomodoros_semana = sum(conchas_para(s.segundos) for s in de_la_semana)
    total_materias = len(materias)

    por_semana: dict[date, set[str]] = {}
    for s in sesiones:
        por_semana.setdefault(inicio_semana(s.inicio), set()).add(s.materia_id)
    materias_semana = max((len(v) for v in por_semana.values()), default=0)
    horas_semana = sum(s.segundos // 60 for s in de_la_semana) / 60
    meta_semana = sum(m.meta_semanal_horas for m in materias)

    por_dia: dict[date, int] = {}
    for s in completas:
        por_dia[s.inicio.date()] = por_dia.get(s.inicio.date(), 0) + conchas_para(s.segundos)
    max_dia = max(por_dia.values(), default=0)

    mejor = max(mejor_racha, racha_actual)

    def racha(meta: int) -> int:
        # Se desbloquea con la mejor racha; mientras tanto muestra la actual.
        return mejor if mejor >= meta else racha_actual

    mas_temprano = min(completas, key=lambda s: s.inicio.hour * 60 + s.inicio.minute, default=None)
    madrugador = mas_temprano is not None and mas_temprano.inicio.hour < 8
    fin_de_semana = any(s.inicio.weekday() >= 5 for s in completas)

    def l(id_, nombre, desc, actual, meta, unidad="", nota=None):
        return {
            "id": id_,
            "nombre": nombre,
            "descripcion": desc,
            "valor_actual": math.floor(actual),
            "valor_meta": math.ceil(meta),
            "unidad": unidad,
            "nota": nota,
            "desbloqueado": math.floor(actual) >= math.ceil(meta),
        }

    return [
        l("primer_pomodoro", "Primer pomodoro", "Completa tu primer pomodoro", pomodoros, 1, "pomodoro"),
        l("constante", "Constante", "Completa 5 pomodoros en una semana", pomodoros_semana, 5, "pomodoros"),
        l("racha_7", "Racha de 7 días", "Estudia 7 días seguidos", racha(7), 7, "días"),
        l(
            "todas_materias",
            "Todas tus materias",
            f"Estudia tus {total_materias} materias en una semana",
            materias_semana,
            total_materias or 1,
            "materias",
        ),
        l("experto", "Experto", "Acumula 50 h de estudio", horas_totales, 50, "h"),
        l("racha_14", "Racha de 14 días", "Estudia 14 días seguidos", racha(14), 14, "días"),
        l("meta_cumplida", "Meta cumplida", "Cumple tu meta semanal al 100%", horas_semana, meta_semana or 1, "h"),
        l("maraton", "Maratón", "Completa 10 pomodoros en un día", max_dia, 10, "pomodoros"),
        l("maestro", "Maestro", "Acumula 150 h de estudio", horas_totales, 150, "h"),
        l("pescador", "Pescador experto", "Atrapa 50 peces en Pesca rápida", peces_totales, 50, "peces"),
        l(
            "madrugador",
            "Madrugador",
            "Completa un pomodoro antes de las 8 a. m.",
            1 if madrugador else 0,
            1,
            nota="Aún no lo logras" if mas_temprano is None else f"Tu más temprano: {_hora(mas_temprano.inicio)}",
        ),
        l(
            "fin_de_semana",
            "Fin de semana",
            "Completa un pomodoro un sábado o domingo",
            1 if fin_de_semana else 0,
            1,
            nota="Aún no lo logras",
        ),
    ]
