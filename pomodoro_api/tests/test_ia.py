"""Mensajes de la mascota con IA: Gemini simulado, sin llamadas reales."""

import httpx

from app import ia
from tests.test_api import _registrar, api  # noqa: F401 (fixture)


def _nacer(api, h):
    materia = api.post(
        "/materias", json={"nombre": "Cálculo", "horas_totales": 48, "semanas_semestre": 16}, headers=h
    ).json()
    s = api.post("/sesiones", json={"materia_id": materia["id"], "minutos_planeados": 25}, headers=h).json()
    api.post(f"/sesiones/{s['id']}/finalizar", json={"segundos_estudiados": 1500, "estado": "completada"}, headers=h)
    api.put("/mascota/nombre", json={"nombre": "Pompi"}, headers=h)


def test_huevo_tiene_mensaje_fijo(api):
    h = _registrar(api)
    r = api.get("/mascota/mensaje", headers=h).json()
    assert r == {"mensaje": "Completa un pomodoro de 25 min y naceré.", "fuente": "respaldo"}


def test_sin_clave_usa_respaldo(api, monkeypatch):
    monkeypatch.setenv("GEMINI_API_KEY", "")
    h = _registrar(api)
    _nacer(api, h)
    r = api.get("/mascota/mensaje", headers=h).json()
    assert r["fuente"] == "respaldo" and r["mensaje"]


def test_con_ia_envia_los_datos_y_guarda_en_cache(api, monkeypatch):
    ia._cache.clear()
    contextos = []

    def falso(contexto):
        contextos.append(contexto)
        return "¡Hola Ana! Soy Pompi y llevamos 1 día de racha."

    monkeypatch.setattr(ia, "llamar_gemini", falso)
    h = _registrar(api)
    _nacer(api, h)
    r1 = api.get("/mascota/mensaje", headers=h).json()
    r2 = api.get("/mascota/mensaje", headers=h).json()
    assert r1 == r2 == {"mensaje": "¡Hola Ana! Soy Pompi y llevamos 1 día de racha.", "fuente": "ia"}
    assert len(contextos) == 1  # La segunda vez sale de la caché.
    c = contextos[0]
    assert c.nombre_mascota == "Pompi" and c.nombre_estudiante == "Ana"
    assert c.racha_dias == 1 and c.minutos_hoy == 25 and c.conchas == 1
    # 48 h / 16 semanas = 3 h por semana: 25 min no alcanzan salvo el lunes.
    assert c.materias_atrasadas in ((), ("Cálculo",))

    # Si cambia la situación (acariciar sube la felicidad), se pide otro mensaje.
    api.post("/mascota/acariciar", headers=h)
    api.post("/mascota/acariciar", headers=h)
    api.get("/mascota/mensaje", headers=h)
    assert len(contextos) == 2


def test_si_gemini_falla_usa_respaldo(api, monkeypatch):
    ia._cache.clear()
    monkeypatch.setattr(ia, "llamar_gemini", lambda c: None)
    h = _registrar(api)
    _nacer(api, h)
    assert api.get("/mascota/mensaje", headers=h).json()["fuente"] == "respaldo"


def test_llamar_gemini_lee_la_respuesta(monkeypatch):
    monkeypatch.setenv("SUPABASE_URL", "http://falso")
    monkeypatch.setenv("SUPABASE_PUBLISHABLE_KEY", "pub")
    monkeypatch.setenv("SUPABASE_SECRET_KEY", "sec")
    monkeypatch.setenv("GEMINI_API_KEY", "clave-de-prueba")
    from app import config

    config.ajustes.cache_clear()
    enviado = {}

    def post(url, headers, json, timeout):
        enviado.update(url=url, headers=headers, cuerpo=json)
        datos = {"candidates": [{"content": {"parts": [{"text": '"¡Vamos por un pomodoro!"\n'}]}}]}
        return httpx.Response(200, json=datos, request=httpx.Request("POST", url))

    monkeypatch.setattr(ia.httpx, "post", post)
    c = ia.Contexto("Pompi", "Ana", 60, 3, 2, 1, 0, "tarde", ("Física",))
    assert ia.llamar_gemini(c) == "¡Vamos por un pomodoro!"
    assert enviado["headers"]["x-goog-api-key"] == "clave-de-prueba"
    assert "gemini-3.5-flash-lite:generateContent" in enviado["url"]
    assert "Física" in enviado["cuerpo"]["contents"][0]["parts"][0]["text"]

    def falla(*a, **k):
        raise httpx.ConnectError("sin red")

    monkeypatch.setattr(ia.httpx, "post", falla)
    assert ia.llamar_gemini(c) is None
    config.ajustes.cache_clear()


def test_limpiar_recorta_a_una_frase():
    assert ia.limpiar("\n  **Hola**  \notra línea") == "Hola"
    largo = ia.limpiar("palabra " * 40)
    assert len(largo) <= ia.MAX_CARACTERES + 1 and largo.endswith("…")
    assert ia.limpiar("   ") is None


def test_respaldos_caben_en_el_globo():
    base = dict(nombre_mascota="Pompi", nombre_estudiante="Ana", felicidad=50, racha_dias=120,
                panes=2, conchas=3, momento_del_dia="tarde")
    larga = ("Programación Orientada a Objetos y Estructuras de Datos",)
    for minutos in (0, 30, 999):
        for atrasadas in ((), larga):
            for aviso in (None, "pan_usado"):
                c = ia.Contexto(minutos_hoy=minutos, materias_atrasadas=atrasadas, aviso=aviso, **base)
                assert len(ia.mensaje_respaldo(c)) <= ia.MAX_CARACTERES + 1
