import '../../../domain/models/configuracion_pomodoro.dart';
import '../../../utils/result.dart';
import '../../services/local_data_service.dart';
import 'configuracion_repository.dart';

class ConfiguracionRepositoryLocal implements ConfiguracionRepository {
  ConfiguracionRepositoryLocal({required LocalDataService localDataService})
    : _data = localDataService;

  final LocalDataService _data;

  @override
  Future<Result<ConfiguracionPomodoro>> obtener() async =>
      Result.ok(_data.configuracion);

  @override
  Future<Result<void>> guardar(ConfiguracionPomodoro configuracion) async {
    if (!configuracion.esValida) {
      return Result.error(
        Exception(
          'La sesión debe durar entre 5 y 60 min, el descanso corto entre 3 '
          'y 15 min y el descanso largo entre 5 y 30 min.',
        ),
      );
    }
    _data.configuracion = configuracion;
    return const Result.ok(null);
  }
}
