import '../../../domain/models/logro.dart';
import '../../../utils/result.dart';

/// Logros e insignias (RF-009).
abstract class LogroRepository {
  Future<Result<List<Logro>>> obtenerLogros();
}
