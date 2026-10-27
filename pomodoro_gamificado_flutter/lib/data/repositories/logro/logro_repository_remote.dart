import '../../../domain/models/logro.dart';
import '../../../utils/result.dart';
import '../../services/api_client.dart';
import 'logro_repository.dart';

/// Las 12 insignias las calcula la API con las sesiones guardadas.
class LogroRepositoryRemote implements LogroRepository {
  LogroRepositoryRemote({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  @override
  Future<Result<List<Logro>>> obtenerLogros() async {
    final r = await _api.get('/logros');
    return r.como(
      (d) => [
        for (final x in d as List)
          if (x is Map<String, dynamic>)
            Logro(
              id: x['id'] as String,
              nombre: x['nombre'] as String,
              descripcion: x['descripcion'] as String,
              valorActual: x['valor_actual'] as int,
              valorMeta: x['valor_meta'] as int,
              unidad: x['unidad'] as String? ?? '',
              nota: x['nota'] as String?,
            ),
      ],
    );
  }
}
