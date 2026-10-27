import '../../../domain/models/sesion_pomodoro.dart';
import '../../../utils/result.dart';
import '../../services/api_client.dart';
import '../gamificacion/gamificacion_repository_remote.dart';
import 'sesion_repository.dart';

/// El servidor anota la hora de inicio y valida los segundos al cerrar, así
/// las conchas y la racha no se pueden inventar desde la app.
class SesionRepositoryRemote implements SesionRepository {
  SesionRepositoryRemote({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  @override
  Future<Result<String>> iniciarSesion({
    required String materiaId,
    required int minutosPlaneados,
  }) async {
    final r = await _api.post('/sesiones', {
      'materia_id': materiaId,
      'minutos_planeados': minutosPlaneados,
    });
    return r.como((d) => (d as Map<String, dynamic>)['id'] as String);
  }

  @override
  Future<Result<FinDeSesion>> finalizarSesion({
    required String sesionId,
    required SesionPomodoro sesion,
    required int segundos,
    required bool saltada,
  }) async {
    final estado = sesion.completada ? 'completada' : (saltada ? 'saltada' : 'terminada_antes');
    final r = await _api.post('/sesiones/$sesionId/finalizar', {
      'segundos_estudiados': segundos < 0 ? 0 : segundos,
      'estado': estado,
    });
    return r.como((d) {
      final j = d as Map<String, dynamic>;
      return (
        conchas: j['conchas_ganadas'] as int,
        rachaNueva: j['racha_nueva'] as bool,
        mascota: mascotaDesdeJson(j['mascota'] as Map<String, dynamic>),
      );
    });
  }

  @override
  Future<Result<List<SesionPomodoro>>> sesionesEntre(DateTime desde, DateTime hasta) async {
    final r = await _api.get('/sesiones', query: {
      'desde': desde.toUtc().toIso8601String(),
      'hasta': hasta.toUtc().toIso8601String(),
    });
    return r.como(
      (d) => [
        for (final x in d as List)
          if (x is Map<String, dynamic>)
            SesionPomodoro(
              id: x['id'] as String,
              materiaId: x['materia_id'] as String,
              inicio: DateTime.parse(x['iniciada_en'] as String).toLocal(),
              minutosEnfoque: x['minutos_enfoque'] as int,
              completada: x['completada'] as bool,
            ),
      ],
    );
  }
}
