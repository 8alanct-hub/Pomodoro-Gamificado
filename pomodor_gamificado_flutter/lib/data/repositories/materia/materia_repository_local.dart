import '../../../domain/models/materia.dart';
import '../../../utils/result.dart';
import '../../services/local_data_service.dart';
import 'materia_repository.dart';

class MateriaRepositoryLocal implements MateriaRepository {
  MateriaRepositoryLocal({required LocalDataService localDataService})
    : _data = localDataService;

  final LocalDataService _data;

  @override
  Future<Result<List<Materia>>> obtenerMaterias() async =>
      Result.ok(List.unmodifiable(_data.materias));

  @override
  Future<Result<Materia>> agregarMateria({
    required String nombre,
    required double horasTotales,
    required int semanasSemestre,
  }) async {
    if (nombre.trim().isEmpty ||
        horasTotales <= 0 ||
        semanasSemestre < Materia.semanasMin ||
        semanasSemestre > Materia.semanasMax) {
      return Result.error(
        Exception(
          'Revisa los campos: escribe el nombre, unas horas mayores a 0 y '
          'un semestre entre 1 y 24 semanas.',
        ),
      );
    }
    final materia = Materia(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nombre: nombre.trim(),
      horasTotales: horasTotales,
      semanasSemestre: semanasSemestre,
    );
    _data.materias.add(materia);
    return Result.ok(materia);
  }

  @override
  Future<Result<void>> sumarMinutos(String materiaId, int minutos) async {
    final i = _data.materias.indexWhere((m) => m.id == materiaId);
    if (i == -1) return Result.error(Exception('Materia no encontrada'));
    final m = _data.materias[i];
    _data.materias[i] = m.copyWith(
      minutosEstudiados: m.minutosEstudiados + minutos,
    );
    return const Result.ok(null);
  }
}
