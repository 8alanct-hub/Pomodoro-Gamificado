import 'package:flutter/foundation.dart';

import '../../../domain/models/estudiante.dart';
import '../../../utils/result.dart';

/// Registro e inicio de sesión (RF-001 y RF-002).
///
/// Extiende [ChangeNotifier] para que el router redirija al login cuando
/// cambia [isAuthenticated].
abstract class AuthRepository extends ChangeNotifier {
  bool get isAuthenticated;
  Estudiante? get estudiante;

  /// `true` solo justo después de registrarse, para mostrar el tutorial (RF-019).
  bool get debeVerTutorial;

  Future<Result<void>> login({required String correo, required String contrasena});

  Future<Result<void>> registrar({
    required String nombre,
    required String correo,
    required String programa,
    required String contrasena,
  });

  void marcarTutorialVisto();

  /// Cambia el nombre y el programa. El correo no se puede cambiar.
  Future<Result<void>> actualizarPerfil({required String nombre, required String programa});

  Future<Result<void>> logout();
}
