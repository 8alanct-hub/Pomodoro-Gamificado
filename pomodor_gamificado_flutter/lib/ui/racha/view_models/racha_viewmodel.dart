import 'package:flutter/foundation.dart';

import '../../../data/repositories/gamificacion/gamificacion_repository.dart';
import '../../../data/repositories/sesion/sesion_repository.dart';
import '../../../domain/models/mascota.dart';
import '../../../domain/models/sesion_pomodoro.dart';
import '../../../utils/command.dart';
import '../../../utils/formato.dart';
import '../../../utils/result.dart';

/// Estado de cada día en la fila de la semana.
enum DiaRacha { hecho, hoy, pan, futuro, vacio }

/// Pantallas 11 y 12 · Mascota tras un pomodoro: racha activa o eclosión del
/// huevo el primer día de racha (RF-010, RF-014 y RF-015).
class RachaViewModel extends ChangeNotifier {
  RachaViewModel({
    required this.materiaId,
    required this.pomodoro,
    this.finCiclo = false,
    this.completados = 0,
    required GamificacionRepository gamificacionRepository,
    SesionRepository? sesionRepository,
  }) : _repo = gamificacionRepository,
       _sesiones = sesionRepository {
    cargar = Command0(_cargar)..execute();
    guardarNombre = Command1<void, String>(_guardarNombre);
  }

  final String materiaId;
  final int pomodoro;

  /// Era el último pomodoro del ciclo: el botón principal vuelve al inicio.
  final bool finCiclo;

  /// Pomodoros del ciclo completados hasta ahora.
  final int completados;
  final GamificacionRepository _repo;
  final SesionRepository? _sesiones;

  late final Command0<void> cargar;

  /// Nombre obligatorio al nacer (pantalla de eclosión).
  late final Command1<void, String> guardarNombre;

  /// Ya le puso nombre en esta eclosión; hasta entonces no se puede seguir.
  bool nombreListo = false;

  Mascota mascota = const Mascota();
  SesionPomodoro? ultima;
  List<DiaRacha> semana = List.filled(7, DiaRacha.futuro);

  /// En la eclosión el huevo se abre al tocarlo.
  bool huevoAbierto = false;

  /// Día 1 de racha: se muestra la eclosión.
  bool get esEclosion => mascota.rachaDias == 1;

  /// "Pomodoro completado · +25 min · +1 concha".
  String get resumen {
    final u = ultima;
    if (u == null) return 'Pomodoro completado';
    final conchas = u.conchasGanadas;
    return 'Pomodoro completado · +${u.minutosEnfoque} min'
        '${conchas > 0 && !esEclosion ? ' · +${Formato.plural(conchas, 'concha', 'conchas')}' : ''}';
  }

  String get textoPanes {
    if (mascota.panes >= Mascota.maxPanes) return 'Si un día no estudias, un pan protege tu racha.';
    final faltan = 7 - mascota.rachaDias % 7;
    return 'Recuperas otro en ${Formato.plural(faltan, 'día', 'días')} de racha.';
  }

  Future<Result<void>> _guardarNombre(String nombre) async {
    final r = await _repo.ponerNombre(nombre);
    if (r is Error<Mascota>) return Result.error(r.error);
    mascota = (r as Ok<Mascota>).value;
    nombreListo = true;
    notifyListeners();
    return const Result.ok(null);
  }

  void abrirHuevo() {
    huevoAbierto = true;
    notifyListeners();
  }

  Future<Result<void>> _cargar() async {
    final r = await _repo.obtenerMascota();
    if (r is Ok<Mascota>) mascota = r.value;
    final ahora = DateTime.now();
    final hoy = Formato.soloFecha(ahora);
    final lunes = Formato.inicioSemana(ahora);
    var sesiones = const <SesionPomodoro>[];
    if (_sesiones != null) {
      final s = await _sesiones.sesionesEntre(lunes, lunes.add(const Duration(days: 7)));
      if (s is Ok<List<SesionPomodoro>>) sesiones = s.value;
    }
    ultima = sesiones.isEmpty ? null : sesiones.first;
    final inicioRacha = hoy.subtract(Duration(days: mascota.rachaDias - 1));
    semana = [
      for (var i = 0; i < 7; i++)
        () {
          final dia = lunes.add(Duration(days: i));
          final estudio = sesiones.any(
            (s) => Formato.soloFecha(s.inicio) == dia && s.cuentaParaRacha,
          );
          if (dia == hoy) return estudio ? DiaRacha.hoy : DiaRacha.vacio;
          if (dia.isAfter(hoy)) return DiaRacha.futuro;
          if (estudio) return DiaRacha.hecho;
          // Día sin estudio dentro de la racha: lo cubrió un pan.
          return !dia.isBefore(inicioRacha) ? DiaRacha.pan : DiaRacha.vacio;
        }(),
    ];
    notifyListeners();
    return const Result.ok(null);
  }
}
