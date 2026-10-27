import 'package:flutter/foundation.dart';

import '../../../data/repositories/gamificacion/gamificacion_repository.dart';
import '../../../domain/models/mascota.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

enum FasePesca { intro, jugando, fin }

/// Pantalla 14 · Minijuego Pesca rápida (RF-018).
///
/// El movimiento del juego vive en el widget (`JuegoPesca`); este ViewModel
/// maneja las conchas, el puntaje, el récord y la felicidad ganada.
class PescaRapidaViewModel extends ChangeNotifier {
  PescaRapidaViewModel({required GamificacionRepository gamificacionRepository})
    : _repo = gamificacionRepository {
    cargar = Command0(_cargar)..execute();
    empezar = Command0(_empezar);
    terminar = Command1<void, ({int puntos, int peces, String motivo})>(_terminar);
  }

  final GamificacionRepository _repo;

  late final Command0<void> cargar;

  /// Cobra 1 concha e inicia la partida (RF-017 CA-001).
  late final Command0<void> empezar;

  /// Guarda la partida al atrapar basura.
  late final Command1<void, ({int puntos, int peces, String motivo})> terminar;

  FasePesca fase = FasePesca.intro;
  Mascota mascota = const Mascota();
  int puntos = 0;
  bool nuevoRecord = false;
  int felicidadGanada = 0;
  String motivo = '';

  /// Aumenta cada vez que empieza una partida (reinicia el juego).
  int partida = 0;

  int get conchas => mascota.conchas;
  bool get tieneConchas => conchas > 0;

  /// Pez +1, pez dorado +5.
  void sumar(int p) {
    puntos += p;
    notifyListeners();
  }

  Future<Result<void>> _cargar() async {
    final r = await _repo.obtenerMascota();
    if (r is Ok<Mascota>) mascota = r.value;
    notifyListeners();
    return const Result.ok(null);
  }

  Future<Result<void>> _empezar() async {
    final r = await _repo.gastarConcha();
    if (r is Error<Mascota>) return Result.error(r.error);
    mascota = (r as Ok<Mascota>).value;
    puntos = 0;
    nuevoRecord = false;
    felicidadGanada = 0;
    partida++;
    fase = FasePesca.jugando;
    notifyListeners();
    return const Result.ok(null);
  }

  Future<Result<void>> _terminar(({int puntos, int peces, String motivo}) d) async {
    puntos = d.puntos;
    motivo = d.motivo;
    nuevoRecord = puntos > mascota.recordPesca;
    final antes = mascota.felicidad;
    final r = await _repo.guardarPartida(puntaje: puntos, peces: d.peces);
    if (r is Ok<Mascota>) mascota = r.value;
    felicidadGanada = mascota.felicidad - antes;
    fase = FasePesca.fin;
    notifyListeners();
    return const Result.ok(null);
  }
}
