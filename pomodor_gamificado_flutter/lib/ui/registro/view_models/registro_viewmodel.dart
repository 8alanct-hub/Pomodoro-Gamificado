import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

typedef DatosRegistro = ({
  String nombre,
  String correo,
  String programa,
  String contrasena,
  String confirmacion,
});

/// Pantalla 02 · Crear cuenta (RF-001).
class RegistroViewModel extends ChangeNotifier {
  RegistroViewModel({required AuthRepository authRepository})
    : _auth = authRepository {
    registrar = Command1<void, DatosRegistro>(_registrar);
  }

  final AuthRepository _auth;

  /// Al terminar bien, el router lleva al tutorial de bienvenida (RF-019).
  late final Command1<void, DatosRegistro> registrar;

  Future<Result<void>> _registrar(DatosRegistro d) async {
    if (d.contrasena.length < 8) {
      return Result.error(Exception('La contraseña debe tener mínimo 8 caracteres.'));
    }
    if (d.contrasena != d.confirmacion) {
      return Result.error(Exception('Las contraseñas no coinciden.'));
    }
    return _auth.registrar(
      nombre: d.nombre,
      correo: d.correo,
      programa: d.programa,
      contrasena: d.contrasena,
    );
  }
}
