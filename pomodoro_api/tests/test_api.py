"""Recorre las rutas como lo haría la app, con Supabase en memoria."""

import pytest
from fastapi.testclient import TestClient

from tests.falso_supabase import FalsoSupabase


@pytest.fixture
def api(monkeypatch):
    monkeypatch.setenv("SUPABASE_URL", "http://falso")
    monkeypatch.setenv("SUPABASE_PUBLISHABLE_KEY", "pub")
    monkeypatch.setenv("SUPABASE_SECRET_KEY", "sec")
    monkeypatch.setenv("MODO_DESARROLLO", "true")
    from app import config, supabase_cliente

    config.ajustes.cache_clear()
    supabase_cliente.db.cache_clear()
    falso = FalsoSupabase()
    monkeypatch.setattr(supabase_cliente, "create_client", lambda *_: falso)
    from app.main import app

    cliente = TestClient(app, raise_server_exceptions=False)
    cliente.falso = falso
    return cliente


def _registrar(api, correo="ana@utb.edu.co"):
    r = api.post(
        "/auth/registro",
        json={"nombre": "Ana", "correo": correo, "programa": "Ing. de Sistemas", "contrasena": "12345678"},
    )
    assert r.status_code == 201, r.text
    return {"Authorization": f"Bearer {r.json()['access_token']}"}


def test_salud_y_sin_token(api):
    assert api.get("/salud").json() == {"estado": "ok"}
    assert api.get("/mascota").status_code == 401


def test_registro_valida_dominio_y_duplicado(api):
    r = api.post(
        "/auth/registro",
        json={"nombre": "A", "correo": "a@gmail.com", "programa": "X", "contrasena": "12345678"},
    )
    assert r.status_code == 422
    _registrar(api)
    r = api.post(
        "/auth/registro",
        json={"nombre": "A", "correo": "ana@utb.edu.co", "programa": "X", "contrasena": "12345678"},
    )
    assert r.status_code == 409


def test_login_y_perfil(api):
    _registrar(api)
    assert api.post("/auth/login", json={"correo": "ana@utb.edu.co", "contrasena": "mala"}).status_code == 401
    r = api.post("/auth/login", json={"correo": "ana@utb.edu.co", "contrasena": "12345678"})
    h = {"Authorization": f"Bearer {r.json()['access_token']}"}
    assert r.json()["estudiante"]["programa"] == "Ing. de Sistemas"
    r = api.patch("/perfil", json={"nombre": "Ana María", "programa": "Ing. Civil"}, headers=h)
    assert r.json()["nombre"] == "Ana María" and r.json()["correo"] == "ana@utb.edu.co"


def test_configuracion_rechaza_fuera_de_rango(api):
    h = _registrar(api)
    assert api.get("/configuracion", headers=h).json()["enfoque_min"] == 25
    assert api.put("/configuracion", json={"enfoque_min": 27}, headers=h).status_code == 422
    r = api.put("/configuracion", json={"enfoque_min": 50, "pomodoros_por_ciclo": 3}, headers=h)
    assert r.status_code == 200
    assert api.get("/configuracion", headers=h).json()["pomodoros_por_ciclo"] == 3


def test_flujo_completo_estudio_mascota_pesca_logros(api):
    h = _registrar(api)
    m = api.get("/mascota", headers=h).json()
    assert m["estado"] == "huevo" and m["conchas"] == 0

    materia = api.post(
        "/materias", json={"nombre": "Cálculo", "horas_totales": 48, "semanas_semestre": 16}, headers=h
    ).json()

    # Sin conchas no se puede jugar ni ponerle nombre al huevo.
    assert api.post("/pesca/partidas", headers=h).status_code == 409
    assert api.put("/mascota/nombre", json={"nombre": "Pompi"}, headers=h).status_code == 409

    # Pomodoro de 25 min completo: 1 concha, racha 1, nace la mascota.
    s = api.post("/sesiones", json={"materia_id": materia["id"], "minutos_planeados": 25}, headers=h).json()
    r = api.post(
        f"/sesiones/{s['id']}/finalizar", json={"segundos_estudiados": 1500, "estado": "completada"}, headers=h
    ).json()
    assert r["conchas_ganadas"] == 1 and r["racha_nueva"] and r["nacio"]
    assert r["mascota"]["estado"] == "nacida" and r["mascota"]["racha_dias"] == 1
    assert r["mascota"]["panes"] == 2 and r["mascota"]["nombre"] is None

    # No se puede finalizar dos veces.
    assert api.post(
        f"/sesiones/{s['id']}/finalizar", json={"segundos_estudiados": 1500, "estado": "completada"}, headers=h
    ).status_code == 409

    # Segundo pomodoro el mismo día: otra concha, pero no suma racha.
    s2 = api.post("/sesiones", json={"materia_id": materia["id"], "minutos_planeados": 25}, headers=h).json()
    r2 = api.post(
        f"/sesiones/{s2['id']}/finalizar", json={"segundos_estudiados": 9999, "estado": "completada"}, headers=h
    ).json()
    assert r2["conchas_ganadas"] == 1  # se limita a los 25 min planeados
    assert not r2["racha_nueva"] and r2["mascota"]["racha_dias"] == 1 and r2["mascota"]["conchas"] == 2

    # Nombre obligatorio.
    assert api.put("/mascota/nombre", json={"nombre": "   "}, headers=h).status_code == 422
    assert api.put("/mascota/nombre", json={"nombre": " Pompi "}, headers=h).json()["nombre"] == "Pompi"

    # Pesca: cuesta 1 concha y da felicidad.
    p = api.post("/pesca/partidas", headers=h).json()
    assert p["conchas"] == 1
    m = api.post(
        f"/pesca/partidas/{p['partida_id']}/finalizar",
        json={"puntos": 12, "peces": 5, "duracion_segundos": 60, "motivo_fin": "basura"},
        headers=h,
    ).json()
    assert m["felicidad"] == 56 and m["record_pesca"] == 12 and m["peces_totales"] == 5 and m["conchas"] == 1
    assert api.post(
        f"/pesca/partidas/{p['partida_id']}/finalizar",
        json={"puntos": 99, "peces": 50, "duracion_segundos": 60, "motivo_fin": "basura"},
        headers=h,
    ).status_code == 409

    assert api.post("/mascota/acariciar", headers=h).json()["felicidad"] == 61

    # Materias suman lo estudiado.
    assert api.get("/materias", headers=h).json()[0]["minutos_estudiados"] == 50

    # Historial y logros.
    hist = api.get(
        "/sesiones", params={"desde": "2000-01-01T00:00:00+00:00", "hasta": "2100-01-01T00:00:00+00:00"}, headers=h
    ).json()
    assert len(hist) == 2 and all(x["completada"] for x in hist)
    logros = {l["id"]: l for l in api.get("/logros", headers=h).json()}
    assert logros["primer_pomodoro"]["desbloqueado"] and logros["pescador"]["valor_actual"] == 5


def test_no_se_ve_la_materia_de_otro(api):
    h1 = _registrar(api, "ana@utb.edu.co")
    h2 = _registrar(api, "luis@utb.edu.co")
    materia = api.post(
        "/materias", json={"nombre": "Física", "horas_totales": 32, "semanas_semestre": 16}, headers=h1
    ).json()
    assert api.get("/materias", headers=h2).json() == []
    r = api.post("/sesiones", json={"materia_id": materia["id"], "minutos_planeados": 25}, headers=h2)
    assert r.status_code == 404


def test_registro_que_falla_se_deshace_y_responde_con_cors(api):
    api.falso.tablas_bloqueadas = {"perfiles"}
    datos = {"nombre": "Ana", "correo": "ana@utb.edu.co", "programa": "X", "contrasena": "12345678"}
    r = api.post("/auth/registro", json=datos, headers={"Origin": "http://localhost:5000"})
    assert r.status_code == 500
    assert r.json()["detail"] == "El servidor tuvo un problema. Intenta de nuevo."
    assert r.headers.get("access-control-allow-origin") == "*"
    # El usuario se borró: al arreglar el problema puede registrarse de nuevo.
    assert "ana@utb.edu.co" not in api.falso.usuarios
    api.falso.tablas_bloqueadas = set()
    assert api.post("/auth/registro", json=datos).status_code == 201
