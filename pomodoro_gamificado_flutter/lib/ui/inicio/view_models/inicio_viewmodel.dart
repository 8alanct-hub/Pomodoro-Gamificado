import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/gamificacion/gamificacion_repository.dart';
import '../../../data/repositories/logro/logro_repository.dart';
import '../../../data/repositories/materia/materia_repository.dart';
import '../../../data/repositories/sesion/sesion_repository.dart';
import '../../../domain/models/logro.dart';
import '../../../domain/models/mascota.dart';
import '../../../domain/models/materia.dart';
import '../../../domain/models/sesion_pomodoro.dart';
import '../../../utils/command.dart';
import '../../../utils/formato.dart';
import '../../../utils/result.dart';
import '../../core/view_models/resumen_materia.dart';

/// Pantalla 03 · Inicio: saludo, racha, meta semanal, materias e insignia.
class InicioViewModel extends ChangeNotifier {
  InicioViewModel({
    required AuthRepository authRepository,
    required MateriaRepository materiaRepository,
    required SesionRepository sesionRepository,
    required GamificacionRepository gamificacionRepository,
    required LogroRepository logroRepository,
  }) : _auth = authRepository,
       _materias = materiaRepository,
       _sesiones = sesionRepository,
       _gamificacion = gamificacionRepository,
       _logros = logroRepository {
    cargar = Command0(_cargar)..execute();
  }

  final AuthRepository _auth;
  final MateriaRepository _materias;
  final SesionRepository _sesiones;
  final GamificacionRepository _gamificacion;
  final LogroRepository _logros;

  late final Command0<void> cargar;

  List<ResumenMateria> materias = [];
  Mascota mascota = const Mascota();

  /// Última insignia desbloqueada, para el aviso de abajo.
  Logro? insignia;

  String get nombre {
    final n = _auth.estudiante?.nombre.trim() ?? '';
    return n.isEmpty ? 'Hola' : 'Hola, ${n.split(' ').first}';
  }

  String get iniciales {
    final partes = (_auth.estudiante?.nombre ?? '').trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return partes.take(2).map((p) => p[0].toUpperCase()).join();
  }

  String get fecha => Formato.fechaLarga(DateTime.now());

  double get horasSemana => materias.fold(0, (t, m) => t + m.horasSemana);
  double get metaSemana => materias.fold(0, (t, m) => t + m.metaHoras);
  double get progresoSemana => metaSemana == 0 ? 0 : (horasSemana / metaSemana).clamp(0, 1).toDouble();

  String get textoFalta {
    if (metaSemana == 0) return 'Agrega una materia para calcular tu meta';
    final falta = metaSemana - horasSemana;
    if (falta <= 0) return '¡Cumpliste tu meta semanal!';
    return 'Te faltan ${Formato.horas(falta)} para cumplir tu meta';
  }

  Future<Result<void>> _cargar() async {
    // RF-010 / RF-015: al abrir la app se revisan los días sin estudiar.
    await _gamificacion.revisarRachaDelDia();
    final inicio = Formato.inicioSemana(DateTime.now());
    final m = await _materias.obtenerMaterias();
    final s = await _sesiones.sesionesEntre(inicio, inicio.add(const Duration(days: 7)));
    final g = await _gamificacion.obtenerMascota();
    final l = await _logros.obtenerLogros();
    if (m is Error<List<Materia>>) return Result.error(m.error);
    final lista = (m as Ok<List<Materia>>).value;
    final sesiones = s is Ok<List<SesionPomodoro>> ? s.value : <SesionPomodoro>[];
    materias = ResumenMateria.deLaSemana(lista, sesiones);
    if (g is Ok<Mascota>) mascota = g.value;
    if (l is Ok<List<Logro>>) {
      final ganadas = l.value.where((x) => x.desbloqueado).toList();
      insignia = ganadas.isEmpty ? null : ganadas.last;
    }
    notifyListeners();
    return const Result.ok(null);
  }
}
