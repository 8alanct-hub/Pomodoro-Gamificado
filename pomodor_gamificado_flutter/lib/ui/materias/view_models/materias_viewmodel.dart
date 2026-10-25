import 'package:flutter/foundation.dart';

import '../../../data/repositories/materia/materia_repository.dart';
import '../../../data/repositories/sesion/sesion_repository.dart';
import '../../../domain/models/materia.dart';
import '../../../domain/models/sesion_pomodoro.dart';
import '../../../utils/command.dart';
import '../../../utils/formato.dart';
import '../../../utils/result.dart';
import '../../core/view_models/resumen_materia.dart';

/// Pantalla 04 · Mis materias (RF-003, RF-004 y RF-012).
class MateriasViewModel extends ChangeNotifier {
  MateriasViewModel({
    required MateriaRepository materiaRepository,
    required SesionRepository sesionRepository,
  }) : _repo = materiaRepository,
       _sesiones = sesionRepository {
    cargar = Command0(_cargar)..execute();
  }

  final MateriaRepository _repo;
  final SesionRepository _sesiones;

  late final Command0<void> cargar;

  List<ResumenMateria> materias = [];

  /// Consejo del sílabo; se cierra con la X.
  bool consejoVisible = true;

  void cerrarConsejo() {
    consejoVisible = false;
    notifyListeners();
  }

  Future<Result<void>> _cargar() async {
    final inicio = Formato.inicioSemana(DateTime.now());
    final r = await _repo.obtenerMaterias();
    final s = await _sesiones.sesionesEntre(inicio, inicio.add(const Duration(days: 7)));
    if (r is Error<List<Materia>>) return Result.error(r.error);
    materias = ResumenMateria.deLaSemana(
      (r as Ok<List<Materia>>).value,
      s is Ok<List<SesionPomodoro>> ? s.value : const [],
    );
    notifyListeners();
    return const Result.ok(null);
  }
}
