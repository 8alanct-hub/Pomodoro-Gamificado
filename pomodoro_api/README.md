# Pomodoro UTB API

Backend del Pomodoro gamificado con **FastAPI + Supabase**. La base de datos y el login
viven en Supabase; la API pone las reglas del juego (conchas, racha, panes, mascota,
pesca y logros) para que la app no las pueda alterar.

## 1. Preparar la base de datos (una sola vez)

En Supabase → **SQL Editor**, corre los dos archivos de `migraciones/`:

- `002_permisos_service_role.sql`: le da a la API (rol `service_role`) permiso para
  leer y escribir las tablas. Sin esto Supabase responde 403.
- `001_ajustes_app.sql`: agrega columnas que la app usa y faltaban:

| Tabla | Columna | Para qué |
|---|---|---|
| `mascotas` | `nombre` | Nombre obligatorio al nacer |
| `partidas_pesca` | `peces` | Insignia "Pescador experto" |
| `configuracion_pomodoro` | `pomodoros_por_ciclo` | Pomodoros por ciclo (1–8) |

## 2. Correr la API (Windows)

```powershell
cd pomodoro_api
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env      # y llena las claves
uvicorn app.main:app --reload
```

Abre <http://127.0.0.1:8000/docs> para probar todo desde el navegador
(botón **Authorize** → pega el `access_token` del login).

Claves en Supabase → Project Settings → **API Keys**:
- `SUPABASE_PUBLISHABLE_KEY`: la pública (`sb_publishable_...`).
- `SUPABASE_SECRET_KEY`: la secreta (`sb_secret_...`). **Solo en el servidor**, nunca
  en Flutter ni en GitHub (`.env` ya está en `.gitignore`).

Pruebas: `python -m pytest` (usan una Supabase falsa en memoria, no tocan la real).

## 3. Rutas

Todas menos `/auth/registro`, `/auth/login`, `/auth/refrescar` y `/salud` piden
`Authorization: Bearer <access_token>`.

| Método | Ruta | Qué hace | RF |
|---|---|---|---|
| POST | `/auth/registro` | Crea la cuenta (solo `@utb.edu.co`) y devuelve la sesión | RF-001 |
| POST | `/auth/login` | Inicia sesión | RF-002 |
| POST | `/auth/refrescar` | Nuevo `access_token` con el `refresh_token` (vence cada hora) | |
| POST | `/auth/logout` | Cierra la sesión | |
| GET / PATCH | `/perfil` | Datos de la cuenta; cambiar nombre y programa | |
| GET / PUT | `/configuracion` | Duraciones del pomodoro (rechaza valores fuera de rango) | RF-006 |
| GET / POST | `/materias` | Materias con minutos estudiados; agregar materia | RF-003, RF-012 |
| POST | `/sesiones` | Empieza un pomodoro (el servidor anota la hora) | RF-005 |
| POST | `/sesiones/{id}/finalizar` | Termina/salta: da conchas, suma racha, devuelve la mascota | RF-010, RF-016 |
| GET | `/sesiones?desde=&hasta=` | Historial para Progreso | RF-011 |
| GET | `/mascota` | Estado; **revisa los días sin estudiar** (llamar al abrir la app) | RF-014, RF-015 |
| POST | `/mascota/acariciar` | +5 de felicidad | |
| PUT | `/mascota/nombre` | Ponerle o cambiarle el nombre (1–20 letras) | |
| POST | `/pesca/partidas` | Gasta 1 concha y empieza una partida | RF-017 |
| POST | `/pesca/partidas/{id}/finalizar` | Guarda puntos y peces; da felicidad (+3, +1 cada 4 pts, máx +20) | RF-017 |
| GET | `/logros` | Las 12 insignias con su avance | RF-009 |

### Cómo lo usa la app en un pomodoro

1. `POST /sesiones` → `{id}`.
2. Al llegar a 00:00, saltar o salir → `POST /sesiones/{id}/finalizar`
   con `segundos_estudiados` y `estado` (`completada`, `saltada`, `terminada_antes`).
3. La respuesta trae `conchas_ganadas`, `racha_nueva` (mostrar la pantalla de racha
   solo si es `true`), `nacio` (pedir el nombre) y la `mascota` actualizada.

### Correr la app Flutter contra la API

Con la API corriendo, en `pomodoro_gamificado_flutter`:

```powershell
flutter pub get
flutter run -t lib/main.dart --dart-define=VELOCIDAD=60
```

- `VELOCIDAD=60` hace que un pomodoro de 25 min dure 25 s (la API debe tener
  `MODO_DESARROLLO=true`). Quítalo para usar el tiempo real.
- La app busca la API en `http://127.0.0.1:8000`. En el emulador de Android usa
  `--dart-define=API_URL=http://10.0.2.2:8000`.
- `lib/main_development.dart` sigue funcionando sin servidor, con las cuentas de prueba.

## 4. Reglas (en `app/reglas.py`)

- 1 concha por cada bloque completo de 25 min de una sesión.
- El primer bloque de 25 min del día suma 1 día de racha.
- Al nacer la mascota recupera 2 panes; después, 1 pan cada 7 días (máximo 2).
- Cada día sin estudiar gasta 1 pan; si no alcanzan, la racha vuelve a 0 y la
  mascota vuelve a huevo (conserva su nombre para sugerirlo al renacer).
- El servidor no acepta más segundos de los planeados ni de los que realmente
  pasaron. Con `MODO_DESARROLLO=true` se omite esto último, porque
  `main_development.dart` corre el reloj 60 veces más rápido.

## Notas

- La clave secreta salta las políticas RLS, por eso **todas** las consultas filtran
  por el `usuario_id` del token. Si agregas rutas, mantén esa regla.
- `rachas_estudio.ultimo_dia_estudiado` guarda el último día *cubierto* (estudiado o
  salvado con un pan).
- Las insignias se calculan al vuelo; las tablas `logros` y `logros_usuario` no se usan
  todavía.
