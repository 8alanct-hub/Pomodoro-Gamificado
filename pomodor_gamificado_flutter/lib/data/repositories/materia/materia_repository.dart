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

  /// Suma minutos de enfoque a la materia (también si la sesión se saltó).
  Future<Result<void>> sumarMinutos(String materiaId, int minutos);
}
