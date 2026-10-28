import '../../../domain/models/mascota.dart';
import '../../../domain/models/sesion_pomodoro.dart';
import '../../../utils/result.dart';
import '../../services/local_data_service.dart';
import '../gamificacion/gamificacion_repository_local.dart';
import '../materia/materia_repository_local.dart';
import 'sesion_repository.dart';

class SesionRepositoryLocal implements SesionRepository {
  SesionRepositoryLocal({
    required LocalDataService localDataService,
    required MateriaRepositoryLocal materias,
    required GamificacionRepositoryLocal gamificacion,
  }) : _data = localDataService,
       _materiaRepo = materias,
       _gamificacionRepo = gamificacion;

  final LocalDataService _data;
  final MateriaRepositoryLocal _materiaRepo;
  final GamificacionRepositoryLocal _gamificacionRepo;

  @override
  Future<Result<String>> iniciarSesion({
    required String materiaId,
    required int minutosPlaneados,
  }) async => Result.ok(DateTime.now().microsecondsSinceEpoch.toString());

  @override
  Future<Result<FinDeSesion>> finalizarSesion({
    required String sesionId,
    required SesionPomodoro sesion,
    required int segundos,
    required bool saltada,
  }) async {
    _data.sesiones.add(sesion);
    // Los minutos siempre suman a estadísticas y meta (RF-005 CA-002).
    await _materiaRepo.sumarMinutos(sesion.materiaId, sesion.minutosEnfoque);
    // Conchas y racha solo con bloques completos de 25 min (RF-005 CA-004).
    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final yaContabaHoy = _data.ultimoDiaConRacha == hoy;
    final r = await _gamificacionRepo.registrarEnfoque(sesion.minutosEnfoque);
    if (r is Error<Mascota>) return Result.error(r.error);
    final mascota = (r as Ok<Mascota>).value;
    return Result.ok((
      conchas: sesion.conchasGanadas,
      // Solo el primer bloque de 25 min del día suma la racha (como la API).
      rachaNueva: sesion.conchasGanadas > 0 && !yaContabaHoy,
      mascota: mascota,
    ));
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
