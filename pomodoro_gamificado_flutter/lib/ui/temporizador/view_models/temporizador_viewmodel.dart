import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../config/desarrollo.dart';
import '../../../data/repositories/configuracion/configuracion_repository.dart';
import '../../../data/repositories/materia/materia_repository.dart';
import '../../../data/repositories/sesion/sesion_repository.dart';
import '../../../domain/models/configuracion_pomodoro.dart';
import '../../../domain/models/materia.dart';
import '../../../domain/models/sesion_pomodoro.dart';
import '../../../utils/command.dart';
import '../../../utils/formato.dart';
import '../../../utils/result.dart';

enum EstadoTemporizador { listo, corriendo, pausado, terminado }

/// Cómo terminó la sesión.
enum AccionFin { completar, saltar, terminar }

/// Lo que ganó el estudiante al cerrar la sesión.
///
/// [rachaNueva] es `true` solo con el primer bloque de 25 min del día: es la
/// única vez que se muestra la pantalla de la mascota y la racha.
typedef ResumenSesion = ({AccionFin accion, int minutos, int conchas, bool rachaNueva});

/// Ícono de cada fila del aviso "Lo que sí / no ganas".
enum IconoAviso { reloj, racha, concha, ciclo }

typedef FilaAviso = ({IconoAviso icono, String texto});

/// Pantalla 07 · Temporizador (RF-005, RF-007, RF-013 y RF-016).
class TemporizadorViewModel extends ChangeNotifier {
  TemporizadorViewModel({
    required this.materiaId,
    required this.pomodoro,
    this.completadosAntes = 0,
    required ConfiguracionRepository configuracionRepository,
    required SesionRepository sesionRepository,
    required MateriaRepository materiaRepository,
  }) : _configuracion = configuracionRepository,
       _sesiones = sesionRepository,
       _materias = materiaRepository {
    cargar = Command0(_cargar)..execute();
    finalizar = Command1<ResumenSesion, AccionFin>(_finalizar);
  }

  final String materiaId;

  /// Número del pomodoro dentro del ciclo (1, 2, 3...).
  final int pomodoro;

  /// Pomodoros del ciclo que ya se completaron antes de este.
  final int completadosAntes;

  final ConfiguracionRepository _configuracion;
  final SesionRepository _sesiones;
  final MateriaRepository _materias;

  /// Id que da el servidor al iniciar la sesión.
  String? _sesionId;

  late final Command0<void> cargar;

  /// Guarda la sesión y aplica recompensas. La vista navega al completar.
  late final Command1<ResumenSesion, AccionFin> finalizar;

  ConfiguracionPomodoro config = const ConfiguracionPomodoro();
  EstadoTemporizador estado = EstadoTemporizador.listo;
  String materiaNombre = '';
  int _minutosHoyAntes = 0;
  double _faltaMetaAntes = 0;
  int _segundosTotales = 25 * 60;
  int _segundosRestantes = 25 * 60;
  DateTime? _inicio;
  Timer? _timer;

  bool get corriendo => estado == EstadoTemporizador.corriendo;

  /// Último pomodoro del ciclo: al terminarlo no hay más descanso.
  bool get esUltimo => pomodoro >= config.pomodorosPorCiclo;

  /// Completados del ciclo contando este si llegó a 00:00.
  int completadosCon(AccionFin accion) => completadosAntes + (accion == AccionFin.completar ? 1 : 0);
  int get totalMin => _segundosTotales ~/ 60;
  double get progreso => 1 - _segundosRestantes / _segundosTotales;

  /// Minutos de enfoque cumplidos hasta ahora (cuentan aunque se salte).
  int get minutosCumplidos => (_segundosTotales - _segundosRestantes) ~/ 60;

  /// Conchas que ya ganó con los bloques completos de 25 min.
  int get conchasGanadas => SesionPomodoro.conchasPara(minutosCumplidos);

  /// Conchas al completar toda la sesión.
  int get conchasAlCompletar => SesionPomodoro.conchasPara(totalMin);

  /// `true` si ya cumplió un bloque: gana racha y conchas aunque salte.
  bool get yaCuentaParaRacha => minutosCumplidos >= SesionPomodoro.minutosPorBloque;

  String get textoTiempo => _mmss(_segundosRestantes);
  String get textoTotal => '$totalMin:00';

  /// "Hoy llevas 2 h 05 min".
  String get textoHoy => 'Hoy llevas ${Formato.duracion(_minutosHoyAntes + minutosCumplidos)}';

  /// "Te faltan 2.5 h para tu meta de Cálculo II".
  String get textoFalta {
    final falta = _faltaMetaAntes - minutosCumplidos / 60;
    if (falta <= 0) return 'Ya cumpliste tu meta semanal de $materiaNombre';
    return 'Te faltan ${Formato.horas(falta)} para tu meta de $materiaNombre';
  }

  /// Lo que sí gana si sale ahora (aviso de la pantalla 7).
  List<FilaAviso> get gana {
    final bloques = conchasGanadas;
    return [
      (icono: IconoAviso.reloj, texto: '$minutosCumplidos min suman a tus estadísticas y a la meta semanal de $materiaNombre'),
      if (bloques > 0) ...[
        (icono: IconoAviso.concha, texto: '+${Formato.plural(bloques, 'concha', 'conchas')} para jugar con tu mascota'),
        (icono: IconoAviso.racha, texto: 'Tu racha de hoy sigue y puedes visitar a tu mascota'),
      ],
    ];
  }

  /// Lo que no gana si sale ahora.
  List<FilaAviso> pierde(AccionFin accion) {
    final bloques = conchasGanadas;
    final falta = SesionPomodoro.minutosPorBloque - minutosCumplidos % SesionPomodoro.minutosPorBloque;
    final n = pomodoro, ciclo = config.pomodorosPorCiclo;
    return [
      if (bloques > 0)
        if ((bloques + 1) * SesionPomodoro.minutosPorBloque <= totalMin)
          (icono: IconoAviso.concha, texto: 'La siguiente concha: te faltan $falta min para ganarla')
        else
          (icono: IconoAviso.reloj, texto: 'Los ${totalMin - minutosCumplidos} min que faltaban para completar la sesión')
      else ...[
        (icono: IconoAviso.racha, texto: 'Racha y mascota: necesitas 25 min completos de enfoque'),
        (icono: IconoAviso.concha, texto: 'Conchas: te faltan $falta min para ganar 1'),
      ],
      if (accion == AccionFin.terminar && n < ciclo)
        (
          icono: IconoAviso.ciclo,
          texto: n + 1 == ciclo
              ? 'El resto del ciclo de hoy (pomodoro $ciclo)'
              : 'El resto del ciclo de hoy (pomodoros ${n + 1} a $ciclo)',
        ),
    ];
  }

  void pausar() {
    if (!corriendo) return;
    _timer?.cancel();
    estado = EstadoTemporizador.pausado;
    notifyListeners();
  }

  void reanudar() {
    if (estado == EstadoTemporizador.terminado) return;
    _inicio ??= DateTime.now();
    estado = EstadoTemporizador.corriendo;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _segundosRestantes -= Desarrollo.velocidad;
      if (_segundosRestantes <= 0) {
        _segundosRestantes = 0;
        finalizar.execute(AccionFin.completar);
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void alternar() => corriendo ? pausar() : reanudar();

  Future<Result<void>> _cargar() async {
    final c = await _configuracion.obtener();
    if (c is Ok<ConfiguracionPomodoro>) config = c.value;
    _segundosTotales = config.enfoqueMin * 60;
    _segundosRestantes = _segundosTotales;

    final m = await _materias.obtenerMaterias();
    final materia = m is Ok<List<Materia>> ? m.value.where((x) => x.id == materiaId).firstOrNull : null;
    materiaNombre = materia?.nombre ?? '';

    final ahora = DateTime.now();
    final hoy = Formato.soloFecha(ahora);
    final semana = Formato.inicioSemana(ahora);
    final s = await _sesiones.sesionesEntre(semana, semana.add(const Duration(days: 7)));
    final sesiones = s is Ok<List<SesionPomodoro>> ? s.value : const <SesionPomodoro>[];
    _minutosHoyAntes = sesiones.where((x) => !x.inicio.isBefore(hoy)).fold(0, (t, x) => t + x.minutosEnfoque);
    final semanaMateria = sesiones.where((x) => x.materiaId == materiaId).fold(0, (t, x) => t + x.minutosEnfoque);
    _faltaMetaAntes = (materia?.metaSemanalHoras ?? 0) - semanaMateria / 60;

    // El servidor anota la hora de inicio (valida los minutos al cerrar).
    final inicio = await _sesiones.iniciarSesion(materiaId: materiaId, minutosPlaneados: config.enfoqueMin);
    if (inicio is Error<String>) return Result.error(inicio.error);
    _sesionId = (inicio as Ok<String>).value;

    // El contador arranca solo al abrir la pantalla.
    reanudar();
    return const Result.ok(null);
  }

  Future<Result<ResumenSesion>> _finalizar(AccionFin accion) async {
    _timer?.cancel();
    estado = EstadoTemporizador.terminado;
    final minutos = minutosCumplidos;
    final sesion = SesionPomodoro(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      materiaId: materiaId,
      inicio: _inicio ?? DateTime.now(),
      minutosEnfoque: minutos,
      completada: accion == AccionFin.completar,
    );
    final id = _sesionId;
    if (id == null) return Result.error(Exception('La sesión no se pudo iniciar.'));
    // Minutos a la materia, conchas y racha (RF-005 CA-002 y CA-004).
    final r = await _sesiones.finalizarSesion(
      sesionId: id,
      sesion: sesion,
      segundos: _segundosTotales - _segundosRestantes,
      saltada: accion == AccionFin.saltar,
    );
    if (r is Error<FinDeSesion>) return Result.error(r.error);
    final fin = (r as Ok<FinDeSesion>).value;
    // TODO: notificación de fin de sesión (RF-007) y revisar logros (RF-009).
    return Result.ok((
      accion: accion,
      minutos: minutos,
      conchas: fin.conchas,
      rachaNueva: fin.rachaNueva,
    ));
  }

  static String _mmss(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
