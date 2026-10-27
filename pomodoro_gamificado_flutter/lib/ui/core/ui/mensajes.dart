import '../../../utils/result.dart';

/// Texto de error para mostrar al usuario a partir de un [Result].
String mensajeDeError(Result<Object?>? resultado) {
  if (resultado is Error<Object?>) {
    return resultado.error.toString().replaceFirst('Exception: ', '');
  }
  return 'Algo salió mal. Intenta de nuevo.';
}
