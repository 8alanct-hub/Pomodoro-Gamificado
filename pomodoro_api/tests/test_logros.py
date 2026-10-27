from datetime import datetime

from app.logros import MateriaLogro, SesionLogro, calcular_logros

AHORA = datetime(2026, 10, 28, 18, 0)  # miércoles


def _por_id(logros):
    return {l["id"]: l for l in logros}


def test_sin_datos_todo_bloqueado():
    ls = calcular_logros([], [], 0, 0, 0, AHORA)
    assert len(ls) == 12
    assert not any(l["desbloqueado"] for l in ls)
    assert _por_id(ls)["madrugador"]["nota"] == "Aún no lo logras"


def test_primer_pomodoro_madrugador_y_fin_de_semana():
    sesiones = [
        SesionLogro(datetime(2026, 10, 28, 7, 30), "m1", 25 * 60),
        SesionLogro(datetime(2026, 10, 25, 10, 0), "m2", 50 * 60),  # domingo anterior
    ]
    ls = _por_id(calcular_logros(sesiones, [MateriaLogro(48, 16)] * 2, 2, 2, 0, AHORA))
    assert ls["primer_pomodoro"]["desbloqueado"]
    assert ls["madrugador"]["desbloqueado"] and ls["madrugador"]["nota"] == "Tu más temprano: 7:30 a. m."
    assert ls["fin_de_semana"]["desbloqueado"]
    assert ls["constante"]["valor_actual"] == 1  # solo cuenta la semana actual


def test_racha_se_desbloquea_con_la_mejor():
    ls = _por_id(calcular_logros([], [], 2, 9, 0, AHORA))
    assert ls["racha_7"]["desbloqueado"] and ls["racha_7"]["valor_actual"] == 9
    assert not ls["racha_14"]["desbloqueado"] and ls["racha_14"]["valor_actual"] == 2
