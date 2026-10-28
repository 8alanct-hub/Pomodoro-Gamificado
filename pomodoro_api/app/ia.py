"""Mensajes de la mascota con IA (Gemini), con respaldo sin IA.

La mascota le habla al estudiante según sus datos reales: racha, panes,
felicidad, lo que estudió hoy y las materias que van atrasadas en la semana.
Si no hay clave de Gemini o la IA falla, se usa un mensaje fijo, así la
pantalla nunca se queda sin texto.
"""

import logging
from dataclasses import dataclass

import httpx

from .config import ajustes

_log = logging.getLogger("pomodoro_api.ia")

# Cabe en 2 líneas del globo de texto sin tapar a la mascota.
MAX_CARACTERES = 80
_URL = "https://generativelanguage.googleapis.com/v1beta/models/{modelo}:generateContent"

_INSTRUCCIONES = f"""Eres la mascota virtual de una app de estudio con la técnica Pomodoro
para estudiantes de la Universidad Tecnológica de Bolívar (UTB).
Hablas en primera persona, en español de Colombia, con tono cariñoso, alegre y breve.
Reglas:
- Responde con UNA sola frase corta: máximo 12 palabras y {MAX_CARACTERES} caracteres.
- No saludes por nombre en cada mensaje; ve directo a lo importante.
- Usa solo los datos que te dan; no inventes materias, cifras ni fechas.
- Si hay una materia atrasada, anima a estudiarla con un pomodoro.
- Si ya estudió hoy, felicítalo; si no, invítalo con suavidad, sin regañar.
- Puedes mencionar tu nombre, la racha o los panes cuando ayude.
- No uses emojis, comillas, hashtags ni listas.
- No des consejos médicos ni hables de temas ajenos al estudio."""


@dataclass(frozen=True)
class Contexto:
    nombre_mascota: str
    nombre_estudiante: str
    felicidad: int
    racha_dias: int
    panes: int
    conchas: int
    minutos_hoy: int
    momento_del_dia: str  # "mañana", "tarde" o "noche"
    materias_atrasadas: tuple[str, ...]  # las que van por debajo de su meta semanal
    aviso: str | None = None  # "pan_usado" o "racha_perdida"

    def como_texto(self) -> str:
        atrasadas = ", ".join(self.materias_atrasadas) or "ninguna"
        lineas = [
            f"Tu nombre: {self.nombre_mascota}",
            f"Estudiante: {self.nombre_estudiante or 'sin nombre'}",
            f"Momento del día: {self.momento_del_dia}",
            f"Racha de días seguidos estudiando: {self.racha_dias}",
            f"Panes (protectores de racha) disponibles: {self.panes} de 2",
            f"Tu felicidad: {self.felicidad} de 100",
            f"Conchas para jugar: {self.conchas}",
            f"Minutos estudiados hoy: {self.minutos_hoy}",
            f"Materias atrasadas esta semana: {atrasadas}",
        ]
        if self.aviso == "pan_usado":
            lineas.append("Hoy se usó un pan porque ayer no estudió; la racha sigue.")
        return "\n".join(lineas)


def mensaje_respaldo(c: Contexto) -> str:
    """Mensaje sin IA, a partir de las mismas reglas."""
    if c.aviso == "pan_usado":
        return "Usé un pan para cuidar la racha. ¡Hoy la seguimos!"
    if c.minutos_hoy >= 25 and c.materias_atrasadas:
        return limpiar(f"¡Bien hecho hoy! ¿Un pomodoro más de {c.materias_atrasadas[0]}?") or "¡Bien hecho hoy!"
    if c.minutos_hoy >= 25:
        return f"¡Estudiaste {c.minutos_hoy} min hoy! Racha de {c.racha_dias} días."
    if c.materias_atrasadas:
        return limpiar(f"¿Hacemos un pomodoro de {c.materias_atrasadas[0]} hoy?") or "¿Hacemos un pomodoro hoy?"
    return "Un pomodoro de 25 min y nuestra racha sigue creciendo."


def limpiar(texto: str) -> str | None:
    """Deja una sola frase corta y sin adornos."""
    linea = next((l.strip() for l in texto.splitlines() if l.strip()), "")
    linea = linea.strip(" \"'“”*#-")
    if not linea:
        return None
    if len(linea) > MAX_CARACTERES:
        corte = linea[:MAX_CARACTERES].rsplit(" ", 1)[0].rstrip(",;:")
        linea = corte + "…"
    return linea


def llamar_gemini(contexto: Contexto) -> str | None:
    """Devuelve la frase de Gemini o None si no hay clave o algo falla."""
    a = ajustes()
    if not a.gemini_api_key:
        return None
    try:
        r = httpx.post(
            _URL.format(modelo=a.gemini_modelo),
            headers={"x-goog-api-key": a.gemini_api_key, "Content-Type": "application/json"},
            json={
                "systemInstruction": {"parts": [{"text": _INSTRUCCIONES}]},
                "contents": [{"role": "user", "parts": [{"text": contexto.como_texto()}]}],
                "generationConfig": {"temperature": 0.9, "maxOutputTokens": 200},
            },
            timeout=10,
        )
        r.raise_for_status()
        partes = r.json()["candidates"][0]["content"]["parts"]
        return limpiar("".join(p.get("text", "") for p in partes))
    except Exception as e:  # Sin IA la app sigue funcionando con el respaldo.
        _log.warning("Gemini no respondió: %s", e)
        return None


# Un mensaje por estudiante mientras su situación no cambie (evita gastar
# llamadas cada vez que se abre la pantalla).
_cache: dict[str, tuple[tuple, str]] = {}


def mensaje_mascota(usuario_id: str, contexto: Contexto, hoy: str) -> tuple[str, str]:
    """Devuelve (mensaje, fuente), donde fuente es "ia" o "respaldo"."""
    clave = (
        hoy,
        contexto.momento_del_dia,
        contexto.racha_dias,
        contexto.panes,
        contexto.felicidad // 10,
        contexto.minutos_hoy // 25,
        contexto.materias_atrasadas,
        contexto.aviso,
    )
    guardado = _cache.get(usuario_id)
    if guardado and guardado[0] == clave:
        return guardado[1], "ia"
    texto = llamar_gemini(contexto)
    if texto is None:
        return mensaje_respaldo(contexto), "respaldo"
    _cache[usuario_id] = (clave, texto)
    return texto, "ia"
