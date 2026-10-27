import 'package:pomodoro_gamificado_flutter/data/repositories/materia/materia_repository.dart';
import 'package:pomodoro_gamificado_flutter/domain/models/materia.dart';
import 'package:pomodoro_gamificado_flutter/utils/result.dart';

/// Repositorio falso para probar ViewModels sin datos reales.
class FakeMateriaRepository implements MateriaRepository {
  FakeMateriaRepository([List<Materia>? materias]) : materias = materias ?? [];

  final List<Materia> materias;

  @override
  Future<Result<List<Materia>>> obtenerMaterias() async => Result.ok(materias);

  @override
  Future<Result<Materia>> agregarMateria({
    required String nombre,
    required double horasTotales,
    required int semanasSemestre,
  }) async {
    final m = Materia(
      id: '${materias.length + 1}',
      nombre: nombre,
      horasTotales: horasTotales,
      semanasSemestre: semanasSemestre,
    );
    materias.add(m);
    return Result.ok(m);
  }
}
