import '../../../domain/models/sesion_pomodoro.dart';
import '../../../utils/result.dart';
import '../../services/local_data_service.dart';
import 'sesion_repository.dart';

class SesionRepositoryLocal implements SesionRepository {
  SesionRepositoryLocal({required LocalDataService localDataService})
    : _data = localDataService;

  final LocalDataService _data;

  @override
  Future<Result<void>> guardarSesion(SesionPomodoro sesion) async {
    _data.sesiones.add(sesion);
    return const Result.ok(null);
  }

  @override
  Future<Result<List<SesionPomodoro>>> sesionesEntre(
    DateTime desde,
    DateTime hasta,
  ) async {
    final lista =
        _data.sesiones
            .where((s) => !s.inicio.isBefore(desde) && s.inicio.isBefore(hasta))
            .toList()
          ..sort((a, b) => b.inicio.compareTo(a.inicio));
    return Result.ok(lista);
  }
}
