import '../../../domain/models/configuracion_pomodoro.dart';
import '../../../utils/result.dart';
import '../../services/api_client.dart';
import 'configuracion_repository.dart';

class ConfiguracionRepositoryRemote implements ConfiguracionRepository {
  ConfiguracionRepositoryRemote({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  @override
  Future<Result<ConfiguracionPomodoro>> obtener() async {
    final r = await _api.get('/configuracion');
    return r.como((d) {
      final j = d as Map<String, dynamic>;
      return ConfiguracionPomodoro(
        enfoqueMin: j['enfoque_min'] as int,
        descansoCortoMin: j['descanso_corto_min'] as int,
        descansoLargoMin: j['descanso_largo_min'] as int,
        pomodorosPorCiclo: j['pomodoros_por_ciclo'] as int,
      );
    });
  }

  @override
  Future<Result<void>> guardar(ConfiguracionPomodoro c) async {
    if (!c.esValida) {
      return Result.error(
        Exception(
          'La sesión debe durar entre 5 y 60 min, el descanso corto entre 3 '
          'y 15 min y el descanso largo entre 5 y 30 min.',
        ),
      );
    }
    final r = await _api.put('/configuracion', {
      'enfoque_min': c.enfoqueMin,
      'descanso_corto_min': c.descansoCortoMin,
      'descanso_largo_min': c.descansoLargoMin,
      'pomodoros_por_ciclo': c.pomodorosPorCiclo,
    });
    return r.como((_) {});
  }
}
