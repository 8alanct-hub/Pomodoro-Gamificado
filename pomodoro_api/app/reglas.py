"""Reglas de gamificación (sin base de datos, para poder probarlas solas).

Son las mismas de la app Flutter (GamificacionRepositoryLocal):
- 1 concha por cada bloque completo de 25 min de enfoque (RF-016).
- El primer bloque de 25 min del día suma 1 día de racha (RF-010).
- Al nacer, la mascota recupera los 2 panes; después, 1 pan cada 7 días de
  racha, máximo 2 (RF-015).
- Si pasan días sin estudiar, se gasta 1 pan por día; si no alcanzan, la racha
  vuelve a 0 y la mascota vuelve a ser huevo (RF-010 CA-002, RF-015 CA-001).
"""

from dataclasses import dataclass, replace
from datetime import date, timedelta

SEGUNDOS_POR_BLOQUE = 25 * 60
MAX_PANES = 2
MAX_NOMBRE = 20
FELICIDAD_CARICIA = 5
FELICIDAD_MAX_PARTIDA = 20


@dataclass(frozen=True)
class EstadoRacha:
    racha_actual: int = 0
    mejor_racha: int = 0
    panes: int = MAX_PANES
    # Último día cubierto: estudiado o salvado con un pan.
    ultimo_dia: date | None = None
    es_huevo: bool = True


def conchas_para(segundos: int) -> int:
    """50 min → 2, 45 min → 1, 20 min → 0."""
    return max(0, segundos) // SEGUNDOS_POR_BLOQUE


def revisar_dias_sin_estudiar(e: EstadoRacha, hoy: date) -> tuple[EstadoRacha, str | None]:
    """Aplica los días perdidos desde `ultimo_dia` hasta ayer.

    Devuelve el estado nuevo y un aviso: "pan_usado", "racha_perdida" o None.
    Es idempotente: llamarla varias veces el mismo día no cambia nada más.
    """
    if e.ultimo_dia is None or e.ultimo_dia >= hoy - timedelta(days=1):
        return e, None
    perdidos = (hoy - e.ultimo_dia).days - 1
    if e.panes >= perdidos:
        return replace(e, panes=e.panes - perdidos, ultimo_dia=hoy - timedelta(days=1)), "pan_usado"
    # Sin panes suficientes: la racha se reinicia y la mascota vuelve a huevo
    # con los 2 panes listos para cuando nazca de nuevo.
    return replace(e, racha_actual=0, panes=MAX_PANES, ultimo_dia=None, es_huevo=True), "racha_perdida"


@dataclass(frozen=True)
class ResultadoDia:
    estado: EstadoRacha
    racha_nueva: bool  # True si este bloque sumó el día de hoy
    nacio: bool  # True si el huevo eclosionó
    aviso: str | None  # resultado de revisar los días perdidos


def registrar_bloque(e: EstadoRacha, hoy: date) -> ResultadoDia:
    """Un bloque de 25 min terminado hoy: cuenta el día para la racha (una vez)."""
    e, aviso = revisar_dias_sin_estudiar(e, hoy)
    if e.ultimo_dia == hoy:
        return ResultadoDia(e, racha_nueva=False, nacio=False, aviso=aviso)
    dias = e.racha_actual + 1
    nacio = e.es_huevo
    if nacio:
        panes = MAX_PANES
    elif dias % 7 == 0:
        panes = min(MAX_PANES, e.panes + 1)
    else:
        panes = e.panes
    nuevo = EstadoRacha(
        racha_actual=dias,
        mejor_racha=max(dias, e.mejor_racha),
        panes=panes,
        ultimo_dia=hoy,
        es_huevo=False,
    )
    return ResultadoDia(nuevo, racha_nueva=True, nacio=nacio, aviso=aviso)


def felicidad_por_partida(puntos: int) -> int:
    """+3 por jugar y +1 por cada 4 puntos, máximo +20."""
    return min(FELICIDAD_MAX_PARTIDA, 3 + max(0, puntos) // 4)


def limpiar_nombre(nombre: str) -> str:
    limpio = " ".join(nombre.split())
    if not 1 <= len(limpio) <= MAX_NOMBRE:
        raise ValueError(f"Escribe un nombre de 1 a {MAX_NOMBRE} letras.")
    return limpio
