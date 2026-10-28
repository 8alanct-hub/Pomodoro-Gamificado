import '../../../domain/models/mascota.dart';
import '../../../domain/models/sesion_pomodoro.dart';
import '../../../utils/result.dart';
import '../../services/local_data_service.dart';
import 'gamificacion_repository.dart';

class GamificacionRepositoryLocal implements GamificacionRepository {
  GamificacionRepositoryLocal({required LocalDataService localDataService})
    : _data = localDataService;

  final LocalDataService _data;
  @override
  Future<Result<Mascota>> obtenerMascota() async => Result.ok(_data.mascota);

  /// Recompensas de una sesión con [minutosEnfoque] cumplidos: conchas por
  /// bloque de 25 min y el día de racha (lo usa SesionRepositoryLocal).
  Future<Result<Mascota>> registrarEnfoque(int minutosEnfoque) async {
    final conchas = SesionPomodoro.conchasPara(minutosEnfoque);
    if (conchas == 0) return Result.ok(_data.mascota);

    var m = _data.mascota.copyWith(conchas: _data.mascota.conchas + conchas);
    final hoy = _soloFecha(DateTime.now());
    if (_data.ultimoDiaConRacha != hoy) {
      _data.ultimoDiaConRacha = hoy;
      final dias = m.rachaDias + 1;
      m = m.copyWith(
        rachaDias: dias,
        mejorRacha: dias > m.mejorRacha ? dias : m.mejorRacha,
        estado: EstadoMascota.nacida,
        // RF-015: al nacer recupera los 2 panes; luego, 1 cada 7 días (máximo 2).
        panes: m.esHuevo ? Mascota.maxPanes : (dias % 7 == 0 ? m.panes + 1 : m.panes),
      );
    }
    _data.mascota = m;
    return Result.ok(m);
  }

  @override
  Future<Result<Mascota>> revisarRachaDelDia() async {
    // TODO: calcular los días sin estudiar desde _data.ultimoDiaConRacha, gastar
    // un pan por día y, si no quedan, reiniciar la racha y volver a huevo
    // (con los 2 panes recuperados para cuando vuelva a nacer).
    return Result.ok(_data.mascota);
  }

  /// Sin servidor no hay IA: mensajes fijos según la racha.
  @override
  Future<Result<String>> mensajeMascota() async {
    final m = _data.mascota;
    if (m.esHuevo) return const Result.ok('Completa un pomodoro de 25 min y naceré.');
    if (_data.ultimoDiaConRacha == _soloFecha(DateTime.now())) {
      return Result.ok('¡Gracias por estudiar hoy! Llevamos ${m.rachaDias} días de racha.');
    }
    return const Result.ok('¡Hola! Un pomodoro de 25 min y nuestra racha sigue creciendo.');
  }

  @override
  Future<Result<Mascota>> acariciar() async {
    _data.mascota = _data.mascota.copyWith(
      felicidad: _data.mascota.felicidad + 5,
    );
    return Result.ok(_data.mascota);
  }

  @override
  Future<Result<Mascota>> ponerNombre(String nombre) async {
    final limpio = nombre.trim();
    if (limpio.isEmpty || limpio.length > Mascota.maxNombre) {
      return Result.error(Exception('Escribe un nombre de 1 a ${Mascota.maxNombre} letras.'));
    }
    _data.mascota = _data.mascota.copyWith(nombre: limpio);
    return Result.ok(_data.mascota);
  }

  @override
  Future<Result<Mascota>> gastarConcha() async {
    if (_data.mascota.conchas < 1) {
      return Result.error(
        Exception('Completa un pomodoro de 25 minutos para ganar una concha.'),
      );
    }
    _data.mascota = _data.mascota.copyWith(conchas: _data.mascota.conchas - 1);
    return Result.ok(_data.mascota);
  }

  @override
  Future<Result<Mascota>> guardarPartida({required int puntaje, required int peces}) async {
    final m = _data.mascota;
    final felicidad = (3 + puntaje ~/ 4).clamp(0, 20);
    _data.mascota = m.copyWith(
      recordPesca: puntaje > m.recordPesca ? puntaje : m.recordPesca,
      felicidad: m.felicidad + felicidad,
      pecesTotales: m.pecesTotales + peces,
    );
    return Result.ok(_data.mascota);
  }

  static DateTime _soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);
}
