@echo off
rem Inicia la API de Pomodoro UTB. Doble clic o, en cmd: iniciar_api
cd /d "%~dp0"

rem La primera vez crea el entorno virtual e instala las dependencias.
if not exist ".venv\Scripts\python.exe" (
    echo Creando el entorno virtual...
    python -m venv .venv
    .venv\Scripts\python -m pip install -r requirements.txt
)

.venv\Scripts\python -m uvicorn app.main:app --reload
pause
