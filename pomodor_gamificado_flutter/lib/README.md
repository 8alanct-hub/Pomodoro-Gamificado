# Organización del código (MVVM)

Sigue la guía de arquitectura de Flutter: https://docs.flutter.dev/app-architecture

```
lib/
├── config/        Dependencias (Provider) y rutas de imágenes
├── data/
│   ├── model/         Modelos de la API (Supabase), con fromJson/toJson
│   ├── repositories/  Una carpeta por tema: interfaz + implementación local
│   └── services/      Acceso a datos (hoy en memoria; luego Supabase)
├── domain/models/ Modelos que usa toda la app (Materia, SesionPomodoro, Mascota…)
├── routing/       Rutas y GoRouter (barra inferior de 5 pestañas)
├── ui/
│   ├── core/          Tema (colores UTB) y widgets compartidos
│   └── <pantalla>/
│       ├── view_models/   Estado y lógica de la pantalla (ChangeNotifier)
│       └── widgets/       La vista (<pantalla>_screen.dart) y sus widgets
├── utils/         Result y Command
├── main.dart              Entrada de producción
└── main_development.dart  Entrada con datos en memoria
test/              Pruebas, con la misma estructura de lib/
testing/           Repositorios falsos y modelos de ejemplo para las pruebas
```

## Reglas

- La vista solo dibuja y llama al ViewModel; no habla con repositorios.
- El ViewModel no importa `material.dart` ni usa `BuildContext`.
- Los repositorios devuelven `Result` (Ok / Error) en vez de lanzar excepciones.
- Una pantalla = una carpeta en `ui/` con un ViewModel.

## Pantallas del prototipo

| Prototipo | Carpeta |
|---|---|
| 01 Iniciar sesión | `ui/login` |
| 02 Registro | `ui/registro` |
| 02b Bienvenida | `ui/bienvenida` |
| 03 Inicio | `ui/inicio` |
| 04 Mis materias | `ui/materias` |
| 05 Agregar materia | `ui/agregar_materia` |
| 06 Nueva sesión | `ui/nueva_sesion` |
| 07 Temporizador | `ui/temporizador` |
| 08 Descanso | `ui/descanso` |
| 09 Progreso | `ui/progreso` |
| 10 Logros | `ui/logros` |
| 11 / 12 / 13 Mascota tras el pomodoro | `ui/racha` |
| 11b Mascota virtual | `ui/mascota` |
| 14 Pesca rápida | `ui/pesca_rapida` |

## Comandos

```
flutter pub get
flutter run --target lib/main_development.dart
flutter analyze
flutter test
```
