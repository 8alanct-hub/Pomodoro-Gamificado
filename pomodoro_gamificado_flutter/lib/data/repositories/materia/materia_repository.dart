import '../../../domain/models/materia.dart';
import '../../../utils/result.dart';

/// Materias del estudiante (RF-003, RF-004 y RF-012).
abstract class MateriaRepository {
  Future<Result<List<Materia>>> obtenerMaterias();

  Future<Result<Materia>> agregarMateria({
    required String nombre,
    required double horasTotales,
    required int semanasSemestre,
  });
}
