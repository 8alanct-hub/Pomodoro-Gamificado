import 'package:flutter/foundation.dart';

import '../../../data/repositories/configuracion/configuracion_repository.dart';
import '../../../data/repositories/materia/materia_repository.dart';
import '../../../data/repositories/sesion/sesion_repository.dart';
import '../../../domain/models/configuracion_pomodoro.dart';
import '../../../domain/models/materia.dart';
import '../../../domain/models/sesion_pomodoro.dart';
import '../../../utils/command.dart';
import '../../../utils/formato.dart';
import '../../../utils/result.dart';
import '../../core/view_models/resumen_materia.dart';

/// Pantalla 06 · Nueva sesión: materia y duraciones (RF-004, RF-006 y RF-016).
class NuevaSesionViewModel extends ChangeNotifier {
  NuevaSesionViewModel({
    required MateriaRepository materiaRepository,
    required ConfiguracionRepository configuracionRepository,
    SesionRepository? sesionRepository,
    this.materiaInicial,
  }) : _materias = materiaRepository,
       _configuracion = configuracionRepository,
       _sesiones = sesionRepository {
    cargar = Command0(_cargar)..execute();
    empezar = Command0(_empezar);
  }

  final MateriaRepository _materias;
  final ConfiguracionRepository _configuracion;
  final SesionRepository? _sesiones;

  /// Materia elegida desde la tarjeta de Inicio o Mis materias.
  final String? materiaInicial;

  late final Command0<void> cargar;

  /// Guarda la configuración; al completar, la vista abre el temporizador.
  late final Command0<void> empezar;

  List<ResumenMateria> materias = [];
  String? materiaId;
  ConfiguracionPomodoro config = const ConfiguracionPomodoro();

  int get conchas => SesionPomodoro.conchasPara(config.enfoqueMin);

  /// Mensaje de conchas según la duración elegida (RF-016).
  String get conchaTitulo => conchas == 0
      ? 'Esta sesión no te da conchas'
      : 'Al completarla ganas ${Formato.plural(conchas, 'concha', 'conchas')}';

  String get conchaTexto {
    final m = config.enfoqueMin;
    final resto = m % SesionPomodoro.minutosPorBloque;
    if (conchas == 0) {
      return 'Las conchas se ganan por cada 25 min de enfoque completados en una misma sesión. '
          'Sube a 25 min para ganar 1 concha y jugar con tu mascota.';
    }
    if (resto == 0) {
      return '$m min de enfoque = ${Formato.plural(conchas, 'bloque', 'bloques')} de 25 min. '
          'Si saltas la sesión, no ganas conchas.';
    }
    return 'Solo cuentan bloques completos de 25 min: los $resto min extra no suman. '
        'Con ${(conchas + 1) * 25} min ganarías ${conchas + 1}.';
  }

  void seleccionarMateria(String id) {
    materiaId = id;
    notifyListeners();
  }

  // Botones − / + con los rangos de RF-006.
  void cambiarEnfoque(int delta) => _set(config.copyWith(
    enfoqueMin: (config.enfoqueMin + delta * ConfiguracionPomodoro.pasoEnfoque)
        .clamp(ConfiguracionPomodoro.enfoqueMinimo, ConfiguracionPomodoro.enfoqueMaximo),
  ));

  void cambiarDescansoCorto(int delta) => _set(config.copyWith(
    descansoCortoMin: (config.descansoCortoMin + delta)
        .clamp(ConfiguracionPomodoro.cortoMinimo, ConfiguracionPomodoro.cortoMaximo),
  ));

  void cambiarDescansoLargo(int delta) => _set(config.copyWith(
    descansoLargoMin: (config.descansoLargoMin + delta * 5)
        .clamp(ConfiguracionPomodoro.largoMinimo, ConfiguracionPomodoro.largoMaximo),
  ));

  void cambiarCiclo(int delta) => _set(config.copyWith(
    pomodorosPorCiclo: (config.pomodorosPorCiclo + delta)
        .clamp(ConfiguracionPomodoro.cicloMinimo, ConfiguracionPomodoro.cicloMaximo),
  ));

  void _set(ConfiguracionPomodoro c) {
    config = c;
    notifyListeners();
  }

  Future<Result<void>> _cargar() async {
    final m = await _materias.obtenerMaterias();
    final c = await _configuracion.obtener();
    var sesiones = const <SesionPomodoro>[];
    if (_sesiones != null) {
      final inicio = Formato.inicioSemana(DateTime.now());
      final s = await _sesiones.sesionesEntre(inicio, inicio.add(const Duration(days: 7)));
      if (s is Ok<List<SesionPomodoro>>) sesiones = s.value;
    }
    if (m is Ok<List<Materia>>) {
      materias = ResumenMateria.deLaSemana(m.value, sesiones);
      final ids = m.value.map((x) => x.id);
      materiaId ??= ids.contains(materiaInicial) ? materiaInicial : (ids.isEmpty ? null : ids.first);
    }
    if (c is Ok<ConfiguracionPomodoro>) config = c.value;
    notifyListeners();
    return const Result.ok(null);
  }

  Future<Result<void>> _empezar() async {
    if (materiaId == null) {
      return Result.error(Exception('Primero agrega una materia.'));
    }
    return _configuracion.guardar(config);
  }
}
