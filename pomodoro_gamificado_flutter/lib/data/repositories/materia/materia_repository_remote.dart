import '../../../domain/models/materia.dart';
import '../../../utils/result.dart';
import '../../services/api_client.dart';
import 'materia_repository.dart';

class MateriaRepositoryRemote implements MateriaRepository {
  MateriaRepositoryRemote({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  @override
  Future<Result<List<Materia>>> obtenerMaterias() async {
    final r = await _api.get('/materias');
    return r.como((d) => [for (final j in d as List) _materia(j as Map<String, dynamic>)]);
  }

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
          'Revisa los campos: escribe el nombre, unas horas mayores a 0 y un '
          'semestre entre 1 y 24 semanas.',
        ),
      );
    }
    final r = await _api.post('/materias', {
      'nombre': nombre.trim(),
      'horas_totales': horasTotales,
      'semanas_semestre': semanasSemestre,
    });
    return r.como((d) => _materia(d as Map<String, dynamic>));
  }

  static Materia _materia(Map<String, dynamic> j) => Materia(
    id: j['id'] as String,
    nombre: j['nombre'] as String,
    horasTotales: (j['horas_totales'] as num).toDouble(),
    semanasSemestre: j['semanas_semestre'] as int,
    minutosEstudiados: j['minutos_estudiados'] as int? ?? 0,
  );
}
