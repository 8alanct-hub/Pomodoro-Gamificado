import '../../../domain/models/configuracion_pomodoro.dart';
import '../../../utils/result.dart';

/// Duraciones del pomodoro elegidas por el estudiante (RF-006).
abstract class ConfiguracionRepository {
  Future<Result<ConfiguracionPomodoro>> obtener();

  /// Rechaza valores fuera de rango y conserva la última configuración válida.
  Future<Result<void>> guardar(ConfiguracionPomodoro configuracion);
}
