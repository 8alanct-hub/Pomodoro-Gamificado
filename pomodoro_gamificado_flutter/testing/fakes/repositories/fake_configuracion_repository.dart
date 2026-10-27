import 'package:pomodoro_gamificado_flutter/data/repositories/configuracion/configuracion_repository.dart';
import 'package:pomodoro_gamificado_flutter/domain/models/configuracion_pomodoro.dart';
import 'package:pomodoro_gamificado_flutter/utils/result.dart';

class FakeConfiguracionRepository implements ConfiguracionRepository {
  ConfiguracionPomodoro guardada = const ConfiguracionPomodoro();

  @override
  Future<Result<ConfiguracionPomodoro>> obtener() async => Result.ok(guardada);

  @override
  Future<Result<void>> guardar(ConfiguracionPomodoro configuracion) async {
    guardada = configuracion;
    return const Result.ok(null);
  }
}
