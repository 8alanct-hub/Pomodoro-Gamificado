import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../config/desarrollo.dart';
import '../../../data/repositories/configuracion/configuracion_repository.dart';
import '../../../data/repositories/materia/materia_repository.dart';
import '../../../domain/models/configuracion_pomodoro.dart';
import '../../../domain/models/materia.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// Pantalla 08 · Descanso, después de completar o saltar un pomodoro.
class DescansoViewModel extends ChangeNotifier {
  DescansoViewModel({
    required this.materiaId,
    required this.pomodoro,
    required this.saltado,
    this.completados = 0,
    required ConfiguracionRepository configuracionRepository,
    MateriaRepository? materiaRepository,
  }) : _configuracion = configuracionRepository,
       _materias = materiaRepository {
    cargar = Command0(_cargar)..execute();
  }

  final String materiaId;

  /// Pomodoro que acaba de terminar.
  final int pomodoro;
  final bool saltado;

  /// Pomodoros del ciclo completados hasta ahora.
  final int completados;
  final ConfiguracionRepository _configuracion;
  final MateriaRepository? _materias;

  late final Command0<void> cargar;

  ConfiguracionPomodoro config = const ConfiguracionPomodoro();
  String materiaNombre = '';
  int _segundosTotales = 5 * 60;
  int _segundosRestantes = 5 * 60;
  bool corriendo = false;
  bool terminado = false;
  Timer? _timer;

  /// Descanso largo al cerrar el ciclo; corto en los demás.
  bool get esLargo => pomodoro % config.pomodorosPorCiclo == 0;

  int get minutosDescanso => _segundosTotales ~/ 60;

  /// Fracción que queda (el anillo se vacía).
  double get restante => _segundosRestantes / _segundosTotales;

  /// El que sigue; al cerrar el ciclo vuelve a empezar en 1.
  int get siguiente => pomodoro % config.pomodorosPorCiclo + 1;

  /// Descanso después del último pomodoro del ciclo: al terminarlo o
  /// saltarlo se cierran las sesiones del día y se vuelve al inicio.
  bool get finCiclo => pomodoro >= config.pomodorosPorCiclo;

  String get textoTiempo =>
      '${(_segundosRestantes ~/ 60).toString().padLeft(2, '0')}:${(_segundosRestantes % 60).toString().padLeft(2, '0')}';

  String get titulo => saltado ? 'Descansa y vuelve con todo' : '¡Buen trabajo! Tómate un respiro';

  String get subtitulo => saltado
      ? 'Este pomodoro no contó para tu racha, pero tus minutos sí suman a tus estadísticas.'
      : 'Completaste tu pomodoro de $materiaNombre. Tu racha y tu mascota ya están al día.';

  String get estadoTexto =>
      '${corriendo || terminado ? (esLargo ? 'Descanso largo' : 'Descanso corto') : 'Descanso en pausa'} · $minutosDescanso min';

  void alternar() => corriendo ? _pausar() : _correr();

  void _pausar() {
    _timer?.cancel();
    corriendo = false;
    notifyListeners();
  }

  void _correr() {
    if (terminado) return;
    corriendo = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _segundosRestantes -= Desarrollo.velocidad;
      if (_segundosRestantes <= 0) {
        _segundosRestantes = 0;
        terminado = true;
        corriendo = false;
        _timer?.cancel();
        // TODO: notificación de fin de descanso (RF-007 CA-002).
      }
      notifyListeners();
    });
    notifyListeners();
  }

  Future<Result<void>> _cargar() async {
    final c = await _configuracion.obtener();
    if (c is Ok<ConfiguracionPomodoro>) config = c.value;
    if (_materias != null) {
      final m = await _materias.obtenerMaterias();
      if (m is Ok<List<Materia>>) {
        materiaNombre = m.value.where((x) => x.id == materiaId).firstOrNull?.nombre ?? '';
      }
    }
    _segundosTotales = (esLargo ? config.descansoLargoMin : config.descansoCortoMin) * 60;
    _segundosRestantes = _segundosTotales;
    _correr();
    return const Result.ok(null);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
