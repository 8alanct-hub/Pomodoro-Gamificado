from datetime import date, timedelta

import pytest

from app import reglas
from app.reglas import EstadoRacha

HOY = date(2026, 10, 26)
AYER = HOY - timedelta(days=1)


def test_conchas_por_bloques_de_25():
    assert reglas.conchas_para(50 * 60) == 2
    assert reglas.conchas_para(45 * 60) == 1
    assert reglas.conchas_para(20 * 60) == 0


def test_primer_bloque_hace_nacer_y_da_2_panes():
    r = reglas.registrar_bloque(EstadoRacha(panes=0), HOY)
    assert r.nacio and r.racha_nueva
    assert r.estado.racha_actual == 1 and r.estado.panes == 2 and not r.estado.es_huevo


def test_segundo_bloque_del_dia_no_suma_racha():
    e = EstadoRacha(racha_actual=3, mejor_racha=3, panes=1, ultimo_dia=HOY, es_huevo=False)
    r = reglas.registrar_bloque(e, HOY)
    assert not r.racha_nueva and r.estado == e


def test_estudiar_ayer_y_hoy_suma_uno():
    e = EstadoRacha(racha_actual=5, mejor_racha=9, panes=1, ultimo_dia=AYER, es_huevo=False)
    r = reglas.registrar_bloque(e, HOY)
    assert r.estado.racha_actual == 6 and r.estado.mejor_racha == 9 and r.aviso is None


def test_cada_7_dias_recupera_un_pan_maximo_2():
    e = EstadoRacha(racha_actual=6, mejor_racha=6, panes=1, ultimo_dia=AYER, es_huevo=False)
    assert reglas.registrar_bloque(e, HOY).estado.panes == 2
    e2 = EstadoRacha(racha_actual=13, mejor_racha=13, panes=2, ultimo_dia=AYER, es_huevo=False)
    assert reglas.registrar_bloque(e2, HOY).estado.panes == 2


def test_un_dia_sin_estudiar_gasta_un_pan_y_es_idempotente():
    e = EstadoRacha(racha_actual=4, mejor_racha=4, panes=2, ultimo_dia=HOY - timedelta(days=2), es_huevo=False)
    e1, aviso = reglas.revisar_dias_sin_estudiar(e, HOY)
    assert aviso == "pan_usado" and e1.panes == 1 and e1.racha_actual == 4
    e2, aviso2 = reglas.revisar_dias_sin_estudiar(e1, HOY)
    assert aviso2 is None and e2 == e1


def test_sin_panes_suficientes_vuelve_a_huevo():
    e = EstadoRacha(racha_actual=8, mejor_racha=8, panes=1, ultimo_dia=HOY - timedelta(days=4), es_huevo=False)
    e1, aviso = reglas.revisar_dias_sin_estudiar(e, HOY)
    assert aviso == "racha_perdida"
    assert e1.racha_actual == 0 and e1.es_huevo and e1.panes == 2 and e1.mejor_racha == 8
    # Al volver a estudiar renace con racha 1.
    r = reglas.registrar_bloque(e1, HOY)
    assert r.nacio and r.estado.racha_actual == 1


def test_felicidad_por_partida():
    assert reglas.felicidad_por_partida(0) == 3
    assert reglas.felicidad_por_partida(12) == 6
    assert reglas.felicidad_por_partida(500) == 20


def test_nombre_mascota():
    assert reglas.limpiar_nombre("  Pompi   Azul ") == "Pompi Azul"
    with pytest.raises(ValueError):
        reglas.limpiar_nombre("   ")
    with pytest.raises(ValueError):
        reglas.limpiar_nombre("x" * 21)
