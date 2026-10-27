"""Cuerpos de las peticiones y respuestas (los valida FastAPI con Pydantic)."""

from datetime import datetime
from typing import Literal

from pydantic import BaseModel, EmailStr, Field

# ---------- Auth y perfil (RF-001, RF-002) ----------


class Registro(BaseModel):
    nombre: str = Field(min_length=1, max_length=80)
    correo: EmailStr
    programa: str = Field(min_length=1, max_length=120)
    contrasena: str = Field(min_length=8, max_length=72)


class Login(BaseModel):
    correo: EmailStr
    contrasena: str = Field(min_length=1)


class Refrescar(BaseModel):
    refresh_token: str


class Estudiante(BaseModel):
    id: str
    nombre: str
    correo: str
    programa: str


class Sesion(BaseModel):
    access_token: str
    refresh_token: str
    expira_en: int  # segundos
    estudiante: Estudiante


class PerfilCambios(BaseModel):
    nombre: str = Field(min_length=1, max_length=80)
    programa: str = Field(min_length=1, max_length=120)


# ---------- Configuración (RF-006) ----------


class Configuracion(BaseModel):
    enfoque_min: int = Field(25, ge=5, le=60, multiple_of=5)
    descanso_corto_min: int = Field(5, ge=3, le=15)
    descanso_largo_min: int = Field(15, ge=5, le=30)
    pomodoros_por_ciclo: int = Field(4, ge=1, le=8)


# ---------- Materias (RF-003, RF-004, RF-012) ----------


class MateriaNueva(BaseModel):
    nombre: str = Field(min_length=1, max_length=80)
    horas_totales: float = Field(gt=0, le=1000)
    semanas_semestre: int = Field(ge=1, le=24)


class Materia(MateriaNueva):
    id: str
    minutos_estudiados: int


# ---------- Sesiones de estudio (RF-005, RF-011) ----------


class SesionNueva(BaseModel):
    materia_id: str
    minutos_planeados: int = Field(ge=1, le=60)


class SesionIniciada(BaseModel):
    id: str
    iniciada_en: datetime


class SesionFin(BaseModel):
    segundos_estudiados: int = Field(ge=0)
    # completada: llegó a 00:00 · saltada: el estudiante la saltó ·
    # terminada_antes: salió antes de tiempo.
    estado: Literal["completada", "saltada", "terminada_antes"]


class SesionHistorial(BaseModel):
    id: str
    materia_id: str
    iniciada_en: datetime
    minutos_enfoque: int
    completada: bool


# ---------- Mascota, racha y conchas (RF-010, RF-014 a RF-017) ----------


class Mascota(BaseModel):
    estado: Literal["huevo", "nacida"]
    nombre: str | None
    felicidad: int
    racha_dias: int
    mejor_racha: int
    panes: int
    conchas: int
    record_pesca: int
    peces_totales: int
    # Lo que pasó al revisar los días sin estudiar: "pan_usado", "racha_perdida" o null.
    aviso: str | None = None


class ResultadoSesion(BaseModel):
    sesion: SesionHistorial
    conchas_ganadas: int
    racha_nueva: bool  # este pomodoro sumó el día de hoy (mostrar pantalla de racha)
    nacio: bool  # el huevo eclosionó (pedir nombre)
    mascota: Mascota


class NombreMascota(BaseModel):
    nombre: str = Field(min_length=1, max_length=20)


# ---------- Pesca rápida (RF-017) ----------


class PartidaIniciada(BaseModel):
    partida_id: str
    conchas: int


class PartidaFin(BaseModel):
    puntos: int = Field(ge=0, le=10_000)
    peces: int = Field(ge=0, le=1_000)
    duracion_segundos: int = Field(ge=0, le=3_600)
    motivo_fin: Literal["basura", "salida"]


# ---------- Logros (RF-009) ----------


class Logro(BaseModel):
    id: str
    nombre: str
    descripcion: str
    valor_actual: int
    valor_meta: int
    unidad: str
    nota: str | None
    desbloqueado: bool
