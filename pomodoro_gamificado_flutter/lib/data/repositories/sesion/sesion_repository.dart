import '../../../domain/models/mascota.dart';
import '../../../domain/models/sesion_pomodoro.dart';
import '../../../utils/result.dart';

/// Lo que dejó una sesión al cerrarse.
///
/// [rachaNueva] es `true` solo si este bloque sumó el día de hoy a la racha.
typedef FinDeSesion = ({int conchas, bool rachaNueva, Mascota mascota});

/// Sesiones de estudio e historial (RF-005, RF-010, RF-011 y RF-016).
abstract class SesionRepository {
  /// Registra el inicio de un pomodoro y devuelve su id.
  Future<Result<String>> iniciarSesion({required String materiaId, required int minutosPlaneados});

  /// Cierra la sesión [sesionId] con los [segundos] de enfoque cumplidos.
  /// Suma los minutos a la materia y aplica conchas y racha (bloques de 25 min).
  Future<Result<FinDeSesion>> finalizarSesion({
    required String sesionId,
    required SesionPomodoro sesion,
    required int segundos,
    required bool saltada,
  });

  /// Sesiones entre [desde] (incluido) y [hasta] (excluido), de la más
  /// reciente a la más antigua.
  Future<Result<List<SesionPomodoro>>> sesionesEntre(
    DateTime desde,
    DateTime hasta,
  );
}
