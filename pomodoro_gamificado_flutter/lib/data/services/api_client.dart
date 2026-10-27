import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../utils/result.dart';

/// Error que devuelve la API, con un mensaje listo para mostrar.
class ApiException implements Exception {
  const ApiException(this.estado, this.mensaje);

  /// Código HTTP (401, 404, 409, 422...). 0 si no hubo conexión.
  final int estado;
  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Cliente HTTP de la API de FastAPI (`pomodoro_api`).
///
/// Guarda los tokens de la sesión, los envía en cada petición y, si el
/// `access_token` vence (cada hora), pide uno nuevo con el `refresh_token`.
class ApiClient {
  ApiClient({required this.baseUrl, http.Client? cliente}) : _http = cliente ?? http.Client();

  /// Por ejemplo `http://127.0.0.1:8000`.
  final String baseUrl;
  final http.Client _http;

  String? _accessToken;
  String? _refreshToken;

  /// Se llama cuando la sesión venció y no se pudo renovar.
  void Function()? alVencerSesion;

  static const _tiempoMaximo = Duration(seconds: 15);

  bool get tieneSesion => _accessToken != null;

  /// Guarda los tokens de la respuesta de login, registro o refrescar.
  void guardarSesion(Map<String, dynamic> sesion) {
    _accessToken = sesion['access_token'] as String?;
    _refreshToken = sesion['refresh_token'] as String?;
  }

  void borrarSesion() {
    _accessToken = null;
    _refreshToken = null;
  }

  Future<Result<Object?>> get(String ruta, {Map<String, String>? query}) =>
      _enviar('GET', ruta, query: query);

  Future<Result<Object?>> post(String ruta, [Object? cuerpo]) => _enviar('POST', ruta, cuerpo: cuerpo);

  Future<Result<Object?>> put(String ruta, Object? cuerpo) => _enviar('PUT', ruta, cuerpo: cuerpo);

  Future<Result<Object?>> patch(String ruta, Object? cuerpo) => _enviar('PATCH', ruta, cuerpo: cuerpo);

  Future<Result<Object?>> _enviar(
    String metodo,
    String ruta, {
    Object? cuerpo,
    Map<String, String>? query,
    bool reintentar = true,
  }) async {
    final uri = Uri.parse('$baseUrl$ruta').replace(queryParameters: query);
    final http.Response r;
    try {
      final peticion = http.Request(metodo, uri)..headers['Content-Type'] = 'application/json';
      if (_accessToken != null) peticion.headers['Authorization'] = 'Bearer $_accessToken';
      if (cuerpo != null) peticion.body = jsonEncode(cuerpo);
      r = await http.Response.fromStream(await _http.send(peticion).timeout(_tiempoMaximo));
    } on Exception {
      return const Result.error(
        ApiException(0, 'No se pudo conectar con el servidor. Revisa tu conexión.'),
      );
    }

    // Token vencido: se renueva una vez y se repite la petición.
    if (r.statusCode == 401 && reintentar && _refreshToken != null) {
      if (await _refrescar()) {
        return _enviar(metodo, ruta, cuerpo: cuerpo, query: query, reintentar: false);
      }
      borrarSesion();
      alVencerSesion?.call();
    }

    Object? datos;
    try {
      final texto = utf8.decode(r.bodyBytes);
      datos = texto.isEmpty ? null : jsonDecode(texto);
    } on FormatException {
      datos = null;
    }
    if (r.statusCode >= 200 && r.statusCode < 300) return Result.ok(datos);
    return Result.error(ApiException(r.statusCode, _mensaje(r.statusCode, datos)));
  }

  Future<bool> _refrescar() async {
    final token = _refreshToken;
    if (token == null) return false;
    try {
      final r = await _http
          .post(
            Uri.parse('$baseUrl/auth/refrescar'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': token}),
          )
          .timeout(_tiempoMaximo);
      if (r.statusCode != 200) return false;
      guardarSesion(jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>);
      return true;
    } on Exception {
      return false;
    }
  }

  /// FastAPI responde `{"detail": "mensaje"}` o, si falla la validación,
  /// `{"detail": [ ... ]}`.
  static String _mensaje(int estado, Object? datos) {
    final detalle = datos is Map ? datos['detail'] : null;
    if (detalle is String) return detalle;
    if (estado == 422) return 'Revisa los datos ingresados.';
    if (estado == 401) return 'Tu sesión venció. Inicia sesión de nuevo.';
    if (estado >= 500) return 'El servidor tuvo un problema. Intenta de nuevo.';
    return 'Algo salió mal. Intenta de nuevo.';
  }
}

/// Atajos para leer el JSON de las respuestas.
extension LecturaJson on Result<Object?> {
  /// Convierte el cuerpo con [convertir] si la respuesta fue exitosa.
  Result<T> como<T>(T Function(Object? datos) convertir) => switch (this) {
    Ok<Object?>(:final value) => Result.ok(convertir(value)),
    Error<Object?>(:final error) => Result.error(error),
  };
}
