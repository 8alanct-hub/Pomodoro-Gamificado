import 'dart:async';

import 'package:flutter/foundation.dart';

import 'result.dart';

typedef CommandAction0<T> = Future<Result<T>> Function();
typedef CommandAction1<T, A> = Future<Result<T>> Function(A);

/// Envuelve una acción del ViewModel y expone su estado a la vista:
/// [running] mientras se ejecuta, [error] o [completed] al terminar.
///
/// Patrón tomado de la guía de arquitectura de Flutter.
abstract class Command<T> extends ChangeNotifier {
  bool _running = false;
  Result<T>? _result;

  /// `true` mientras la acción se está ejecutando.
  bool get running => _running;

  /// `true` si la última ejecución terminó con error.
  bool get error => _result is Error;

  /// `true` si la última ejecución terminó bien.
  bool get completed => _result is Ok;

  /// Resultado de la última ejecución.
  Result<T>? get result => _result;

  /// Limpia el último resultado.
  void clearResult() {
    _result = null;
    notifyListeners();
  }

  Future<void> _execute(CommandAction0<T> action) async {
    if (_running) return; // Evita ejecuciones dobles (por ejemplo, doble toque).
    _running = true;
    _result = null;
    notifyListeners();
    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

/// Comando sin argumentos.
class Command0<T> extends Command<T> {
  Command0(this._action);

  final CommandAction0<T> _action;

  Future<void> execute() async => _execute(_action);
}

/// Comando con un argumento.
class Command1<T, A> extends Command<T> {
  Command1(this._action);

  final CommandAction1<T, A> _action;

  Future<void> execute(A argument) async => _execute(() => _action(argument));
}
