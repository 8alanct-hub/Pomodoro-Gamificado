import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// Pantalla 01 · Iniciar sesión (RF-002).
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required AuthRepository authRepository})
    : _auth = authRepository {
    login = Command1<void, (String correo, String contrasena)>(_login);
  }

  final AuthRepository _auth;

  /// Al terminar bien, el router redirige solo a Inicio.
  late final Command1<void, (String correo, String contrasena)> login;

  Future<Result<void>> _login((String, String) datos) =>
      _auth.login(correo: datos.$1, contrasena: datos.$2);
}
