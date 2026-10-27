"""Supabase en memoria para probar las rutas sin red (solo lo que usa la API)."""

import uuid
from datetime import datetime, timezone
from types import SimpleNamespace as NS


def _ahora() -> str:
    return datetime.now(timezone.utc).isoformat()


DEFECTOS = {
    "perfiles": lambda: {"zona_horaria": "America/Bogota", "programa_academico": None, "creado_en": _ahora()},
    "configuracion_pomodoro": lambda: {
        "minutos_enfoque": 25, "minutos_descanso_corto": 5, "minutos_descanso_largo": 15,
        "pomodoros_por_ciclo": 4,
    },
    "rachas_estudio": lambda: {"ultimo_dia_estudiado": None, "racha_actual": 0, "mejor_racha": 0, "panes_disponibles": 2},
    "mascotas": lambda: {"estado": "huevo", "felicidad": 50, "nombre": None, "eclosionada_en": None},
    "materias": lambda: {"id": str(uuid.uuid4()), "creada_en": _ahora()},
    "sesiones_estudio": lambda: {
        "id": str(uuid.uuid4()), "iniciada_en": _ahora(), "segundos_estudiados": 0,
        "estado": "en_curso", "finalizada_en": None,
    },
    "actividad_diaria": lambda: {"segundos_enfoque": 0, "pomodoros_completados": 0},
    "movimientos_conchas": lambda: {"id": str(uuid.uuid4()), "creado_en": _ahora()},
    "partidas_pesca": lambda: {
        "id": str(uuid.uuid4()), "iniciada_en": _ahora(), "finalizada_en": None, "puntos": 0,
        "peces": 0, "felicidad_ganada": 0, "duracion_segundos": 0, "motivo_fin": None,
    },
}
LLAVES = {
    "perfiles": ("id",), "configuracion_pomodoro": ("usuario_id",), "rachas_estudio": ("usuario_id",),
    "mascotas": ("usuario_id",), "actividad_diaria": ("usuario_id", "fecha_local"),
}


class Consulta:
    def __init__(self, bd, tabla):
        self.bd, self.tabla = bd, tabla
        self.filtros, self.orden, self.uno, self.op, self.valores = [], None, False, "select", None
        self.not_ = NS(is_=lambda col, _v: self._f(lambda f: f.get(col) is not None))

    def _f(self, fn):
        self.filtros.append(fn)
        return self

    def select(self, *_):
        return self

    def eq(self, c, v):
        return self._f(lambda f: f.get(c) == v)

    def neq(self, c, v):
        return self._f(lambda f: f.get(c) != v)

    def gte(self, c, v):
        return self._f(lambda f: f.get(c) >= v)

    def lt(self, c, v):
        return self._f(lambda f: f.get(c) < v)

    def order(self, c, desc=False):
        self.orden = (c, desc)
        return self

    def maybe_single(self):
        self.uno = True
        return self

    def insert(self, v):
        self.op, self.valores = "insert", v
        return self

    def update(self, v):
        self.op, self.valores = "update", v
        return self

    def upsert(self, v):
        self.op, self.valores = "upsert", v
        return self

    def execute(self):
        filas = self.bd.setdefault(self.tabla, [])
        if self.op == "insert":
            nueva = {**DEFECTOS.get(self.tabla, dict)(), **self.valores}
            filas.append(nueva)
            return NS(data=[dict(nueva)])
        if self.op == "upsert":
            llave = LLAVES[self.tabla]
            for f in filas:
                if all(f.get(k) == self.valores.get(k) for k in llave):
                    f.update(self.valores)
                    return NS(data=[dict(f)])
            nueva = {**DEFECTOS.get(self.tabla, dict)(), **self.valores}
            filas.append(nueva)
            return NS(data=[dict(nueva)])
        elegidas = [f for f in filas if all(fn(f) for fn in self.filtros)]
        if self.op == "update":
            for f in elegidas:
                f.update(self.valores)
            return NS(data=[dict(f) for f in elegidas])
        if self.orden:
            elegidas.sort(key=lambda f: f[self.orden[0]], reverse=self.orden[1])
        if self.uno:
            return NS(data=dict(elegidas[0])) if elegidas else None
        return NS(data=[dict(f) for f in elegidas])


class FalsoSupabase:
    def __init__(self):
        self.bd: dict[str, list[dict]] = {}
        self.usuarios: dict[str, dict] = {}  # correo → {id, contrasena}
        self.tokens: dict[str, NS] = {}
        self.auth = NS(
            get_user=self._get_user,
            sign_in_with_password=self._login,
            refresh_session=lambda _t: (_ for _ in ()).throw(Exception("no")),
            admin=NS(create_user=self._crear, sign_out=lambda _t, *a: None, delete_user=self._borrar),
        )

    # Simula que Supabase rechaza escribir en una tabla (por ejemplo, 403).
    tablas_bloqueadas: set[str] = set()

    def table(self, nombre):
        if nombre in self.tablas_bloqueadas:
            raise Exception("permission denied for table " + nombre)
        return Consulta(self.bd, nombre)

    def _borrar(self, uid):
        for correo, u in list(self.usuarios.items()):
            if u["id"] == uid:
                del self.usuarios[correo]

    def _crear(self, attrs):
        correo = attrs["email"]
        if correo in self.usuarios:
            raise Exception("User already registered")
        uid = str(uuid.uuid4())
        self.usuarios[correo] = {"id": uid, "contrasena": attrs["password"]}
        # Igual que el trigger crear_perfil_y_configuracion.
        nombre = attrs.get("user_metadata", {}).get("nombre")
        Consulta(self.bd, "perfiles").insert({"id": uid, "nombre": nombre}).execute()
        for t in ("configuracion_pomodoro", "rachas_estudio", "mascotas"):
            Consulta(self.bd, t).insert({"usuario_id": uid}).execute()
        return NS(user=NS(id=uid, email=correo))

    def _login(self, cred):
        u = self.usuarios.get(cred["email"])
        if not u or u["contrasena"] != cred["password"]:
            raise Exception("Invalid login credentials")
        token = "tok-" + uuid.uuid4().hex
        user = NS(id=u["id"], email=cred["email"])
        self.tokens[token] = user
        return NS(user=user, session=NS(access_token=token, refresh_token="ref", expires_in=3600))

    def _get_user(self, token):
        u = self.tokens.get(token)
        if not u:
            raise Exception("invalid JWT")
        return NS(user=u)
