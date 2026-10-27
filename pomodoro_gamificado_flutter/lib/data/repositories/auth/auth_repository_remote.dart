import '../../../domain/models/estudiante.dart';
import '../../../utils/result.dart';
import '../../services/api_client.dart';
import 'auth_repository.dart';

/// Registro e inicio de sesión contra la API (Supabase Auth por detrás).
///
/// La sesión vive en memoria: al cerrar la app hay que volver a entrar.
class AuthRepositoryRemote extends AuthRepository {
  AuthRepositoryRemote({required ApiClient apiClient}) : _api = apiClient {
    _api.alVencerSesion = _sesionVencida;
  }

  final ApiClient _api;
  Estudiante? _estudiante;
  bool _debeVerTutorial = false;

  @override
  bool get isAuthenticated => _estudiante != null;

  @override
  Estudiante? get estudiante => _estudiante;

  @override
  bool get debeVerTutorial => _debeVerTutorial;

  @override
  Future<Result<void>> login({required String correo, required String contrasena}) async {
    final r = await _api.post('/auth/login', {'correo': correo.trim(), 'contrasena': contrasena});
    return _iniciar(r);
  }

  @override
  Future<Result<void>> registrar({
    required String nombre,
    required String correo,
    required String programa,
    required String contrasena,
  }) async {
    final r = await _api.post('/auth/registro', {
      'nombre': nombre.trim(),
      'correo': correo.trim(),
      'programa': programa.trim(),
      'contrasena': contrasena,
    });
    if (r is Ok) _debeVerTutorial = true;
    return _iniciar(r);
  }

  Result<void> _iniciar(Result<Object?> r) {
    if (r is Error<Object?>) return Result.error(r.error);
    final sesion = (r as Ok<Object?>).value as Map<String, dynamic>;
    _api.guardarSesion(sesion);
    _estudiante = estudianteDesdeJson(sesion['estudiante'] as Map<String, dynamic>);
    notifyListeners();
    return const Result.ok(null);
  }

  @override
  void marcarTutorialVisto() {
    _debeVerTutorial = false;
    notifyListeners();
  }

  @override
  Future<Result<void>> actualizarPerfil({required String nombre, required String programa}) async {
    if (nombre.trim().isEmpty || programa.trim().isEmpty) {
      return Result.error(Exception('Escribe tu nombre y tu programa académico.'));
    }
    final r = await _api.patch('/perfil', {'nombre': nombre.trim(), 'programa': programa.trim()});
    if (r is Error<Object?>) return Result.error(r.error);
    _estudiante = estudianteDesdeJson((r as Ok<Object?>).value as Map<String, dynamic>);
    notifyListeners();
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> logout() async {
    await _api.post('/auth/logout'); // Si falla, igual se cierra en la app.
    _api.borrarSesion();
    _sesionVencida();
    return const Result.ok(null);
  }

  void _sesionVencida() {
    _estudiante = null;
    _debeVerTutorial = false;
    notifyListeners();
  }
}

Estudiante estudianteDesdeJson(Map<String, dynamic> j) => Estudiante(
  id: j['id'] as String,
  nombre: j['nombre'] as String? ?? '',
  correo: j['correo'] as String? ?? '',
  programa: j['programa'] as String? ?? '',
);
