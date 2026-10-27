import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// Pantalla 03b · Perfil: datos de la cuenta y cerrar sesión (RF-002).
class PerfilViewModel extends ChangeNotifier {
  PerfilViewModel({required AuthRepository authRepository}) : _auth = authRepository {
    guardar = Command1<void, ({String nombre, String programa})>(_guardar);
    cerrarSesion = Command0(_auth.logout);
  }

  final AuthRepository _auth;

  late final Command1<void, ({String nombre, String programa})> guardar;

  /// Al terminar, el router lleva al login porque ya no hay sesión.
  late final Command0<void> cerrarSesion;

  bool editando = false;

  /// "Datos actualizados" después de guardar.
  bool guardado = false;

  String get nombre => _auth.estudiante?.nombre ?? '';
  String get correo => _auth.estudiante?.correo ?? '';
  String get programa {
    final p = _auth.estudiante?.programa ?? '';
    return p.isEmpty ? 'Sin programa' : p;
  }

  String get iniciales => nombre
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .take(2)
      .map((p) => p[0].toUpperCase())
      .join();

  void editar() {
    editando = true;
    guardado = false;
    guardar.clearResult();
    notifyListeners();
  }

  void cancelar() {
    editando = false;
    notifyListeners();
  }

  Future<Result<void>> _guardar(({String nombre, String programa}) d) async {
    final r = await _auth.actualizarPerfil(nombre: d.nombre, programa: d.programa);
    if (r is Ok<void>) {
      editando = false;
      guardado = true;
      notifyListeners();
    }
    return r;
  }
}
