/// Resultado de una operación que puede fallar.
///
/// Los repositorios devuelven [Result] en lugar de lanzar excepciones, así el
/// ViewModel decide qué mostrar en cada caso.
///
/// ```dart
/// switch (resultado) {
///   case Ok(): ...
///   case Error(): ...
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Crea un resultado exitoso con [value].
  const factory Result.ok(T value) = Ok._;

  /// Crea un resultado fallido con [error].
  const factory Result.error(Exception error) = Error._;
}

/// Resultado exitoso.
final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

/// Resultado con error.
final class Error<T> extends Result<T> {
  const Error._(this.error);

  final Exception error;

  @override
  String toString() => 'Result<$T>.error($error)';
}
