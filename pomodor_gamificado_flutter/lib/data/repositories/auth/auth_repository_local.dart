import '../../../domain/models/estudiante.dart';
import '../../../utils/result.dart';
import '../../services/local_data_service.dart';
import 'auth_repository.dart';

/// Implementación en memoria: acepta cualquier correo con formato válido.
class AuthRepositoryLocal extends AuthRepository {
  AuthRepositoryLocal({required LocalDataService localDataService})
    : _data = localDataService;

  final LocalDataService _data;
  bool _debeVerTutorial = false;

  static final _correoValido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  bool get isAuthenticated => _data.estudiante != null;

  @override
  Estudiante? get estudiante => _data.estudiante;

  @override
  bool get debeVerTutorial => _debeVerTutorial;

  @override
  Future<Result<void>> login({
    required String correo,
    required String contrasena,
  }) async {
    final clave = correo.trim().toLowerCase();
    if (!_correoValido.hasMatch(clave) || contrasena.isEmpty) {
      return Result.error(Exception('Correo o contraseña incorrectos.'));
    }
    final cuenta = _data.cuentas[clave];
    if (cuenta != null) {
      // Cuenta conocida (registrada o de prueba): la contraseña debe coincidir.
      if (cuenta.contrasena != contrasena) {
        return Result.error(Exception('Correo o contraseña incorrectos.'));
      }
      if (cuenta.cargar != null) {
        // Cuenta de prueba: cada vez que entra, vuelve a sus datos iniciales.
        _data.reiniciar();
        cuenta.cargar!(_data);
      }
      _data.estudiante = cuenta.estudiante;
    } else {
      // Sin base de datos todavía: cualquier otro correo válido entra vacío.
      _data.reiniciar();
      _data.estudiante = Estudiante(id: clave, nombre: 'Estudiante', correo: clave, programa: '');
    }
    notifyListeners();
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> registrar({
    required String nombre,
    required String correo,
    required String programa,
    required String contrasena,
  }) async {
    if (!_correoValido.hasMatch(correo)) {
      return Result.error(Exception('Correo inválido'));
    }
    final clave = correo.trim().toLowerCase();
    final estudiante = Estudiante(id: clave, nombre: nombre, correo: clave, programa: programa);
    _data.cuentas[clave] = (contrasena: contrasena, estudiante: estudiante, cargar: null);
    _data.reiniciar(); // Una cuenta nueva empieza sin datos.
    _data.estudiante = estudiante;
    _debeVerTutorial = true;
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
    final actual = _data.estudiante;
    if (actual == null) return Result.error(Exception('No hay una sesión iniciada.'));
    if (nombre.trim().isEmpty || programa.trim().isEmpty) {
      return Result.error(Exception('Escribe tu nombre y tu programa académico.'));
    }
    final nuevo = Estudiante(
      id: actual.id,
      nombre: nombre.trim(),
      correo: actual.correo,
      programa: programa.trim(),
    );
    _data.estudiante = nuevo;
    final cuenta = _data.cuentas[actual.correo];
    if (cuenta != null) {
      _data.cuentas[actual.correo] = (contrasena: cuenta.contrasena, estudiante: nuevo, cargar: cuenta.cargar);
    }
    notifyListeners();
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> logout() async {
    _data.estudiante = null;
    notifyListeners();
    return const Result.ok(null);
  }
}
