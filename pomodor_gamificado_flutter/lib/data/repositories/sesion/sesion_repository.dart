import '../../../domain/models/sesion_pomodoro.dart';
import '../../../utils/result.dart';

/// Historial de sesiones (RF-005 y RF-011).
abstract class SesionRepository {
  Future<Result<void>> guardarSesion(SesionPomodoro sesion);

  /// Sesiones entre [desde] (incluido) y [hasta] (excluido), de la más
  /// reciente a la más antigua.
  Future<Result<List<SesionPomodoro>>> sesionesEntre(
    DateTime desde,
    DateTime hasta,
  );
}
