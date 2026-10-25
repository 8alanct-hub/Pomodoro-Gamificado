/// Ajustes solo para probar la app en `main_development.dart`.
abstract final class Desarrollo {
  /// Cuántos segundos avanza el temporizador y el descanso por cada segundo
  /// real. En producción es 1; en desarrollo, 60 (25 min pasan en 25 s).
  static int velocidad = 1;
}
