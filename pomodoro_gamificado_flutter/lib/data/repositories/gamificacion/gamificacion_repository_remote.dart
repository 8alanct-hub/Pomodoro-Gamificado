import '../../../domain/models/mascota.dart';
import '../../../utils/result.dart';
import '../../services/api_client.dart';
import 'gamificacion_repository.dart';

/// Mascota, racha y Pesca rápida: las reglas las aplica la API.
class GamificacionRepositoryRemote implements GamificacionRepository {
  GamificacionRepositoryRemote({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  /// Partida pagada con [gastarConcha] y pendiente de guardar.
  String? _partidaId;
  DateTime? _inicioPartida;

  @override
  Future<Result<Mascota>> obtenerMascota() async => _mascota(await _api.get('/mascota'));

  /// `GET /mascota` ya revisa los días sin estudiar (gasta panes o reinicia).
  @override
  Future<Result<Mascota>> revisarRachaDelDia() => obtenerMascota();

  @override
  Future<Result<Mascota>> acariciar() async => _mascota(await _api.post('/mascota/acariciar'));

  @override
  Future<Result<Mascota>> ponerNombre(String nombre) async {
    final limpio = nombre.trim();
    if (limpio.isEmpty || limpio.length > Mascota.maxNombre) {
      return Result.error(Exception('Escribe un nombre de 1 a ${Mascota.maxNombre} letras.'));
    }
    return _mascota(await _api.put('/mascota/nombre', {'nombre': limpio}));
  }

  @override
  Future<Result<Mascota>> gastarConcha() async {
    final r = await _api.post('/pesca/partidas');
    if (r is Error<Object?>) return Result.error(r.error);
    _partidaId = ((r as Ok<Object?>).value as Map<String, dynamic>)['partida_id'] as String;
    _inicioPartida = DateTime.now();
    return obtenerMascota();
  }

  @override
  Future<Result<Mascota>> guardarPartida({required int puntaje, required int peces}) async {
    final id = _partidaId;
    if (id == null) return Result.error(Exception('No hay una partida en curso.'));
    final segundos = DateTime.now().difference(_inicioPartida ?? DateTime.now()).inSeconds;
    final r = await _api.post('/pesca/partidas/$id/finalizar', {
      'puntos': puntaje,
      'peces': peces,
      'duracion_segundos': segundos.clamp(0, 3600),
      'motivo_fin': 'basura', // La partida solo termina al atrapar basura.
    });
    _partidaId = null;
    return _mascota(r);
  }

  static Result<Mascota> _mascota(Result<Object?> r) =>
      r.como((d) => mascotaDesdeJson(d as Map<String, dynamic>));
}

Mascota mascotaDesdeJson(Map<String, dynamic> j) => Mascota(
  estado: j['estado'] == 'nacida' ? EstadoMascota.nacida : EstadoMascota.huevo,
  nombre: j['nombre'] as String?,
  felicidad: j['felicidad'] as int,
  rachaDias: j['racha_dias'] as int,
  mejorRacha: j['mejor_racha'] as int,
  panes: j['panes'] as int,
  conchas: j['conchas'] as int,
  recordPesca: j['record_pesca'] as int,
  pecesTotales: j['peces_totales'] as int,
);
