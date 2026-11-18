import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Thin wrapper over `package:http` for MindFlow's backend: injects the
/// Bearer JWT, encodes/decodes JSON and surfaces every failure as an
/// [ApiException] (including timeouts, connectivity errors and 401s).
///
/// The base URL can be overridden at build time, e.g. to point the app at a
/// local backend from an Android emulator:
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5080/api/v1`
class ApiClient {
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mindflow-backend-production-898f07da.up.railway.app/api/v1',
  );

  /// Gemini-backed endpoints can take a while; the backend itself gives up on
  /// Gemini after ~50 s, so this stays above that.
  static const defaultTimeout = Duration(seconds: 60);

  final http.Client _client;
  final TokenStorage _tokenStorage;
  final Duration timeout;

  /// Called after a 401 on an authenticated request, once the stored token has
  /// been cleared. The app uses it to send the user back to the login screen.
  void Function()? onUnauthorized;

  ApiClient({http.Client? client, required this._tokenStorage, this.timeout = defaultTimeout})
      : _client = client ?? http.Client();

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _tokenStorage.read();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalized = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$baseUrl/$normalized').replace(
      queryParameters:
          query?.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  /// Runs [call] with a timeout and translates transport errors.
  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      return await call().timeout(timeout);
    } on TimeoutException {
      throw const ApiException(408, 'El servidor tardó demasiado en responder. Intenta de nuevo.');
    } on SocketException {
      throw const ApiException(0, 'No se pudo conectar. Revisa tu conexión e intenta de nuevo.');
    } on http.ClientException {
      throw const ApiException(0, 'No se pudo conectar. Revisa tu conexión e intenta de nuevo.');
    }
  }

  /// Best human-readable message from any of the shapes the backend uses:
  /// `{error}`, `{message}`, ProblemDetails (`detail`/`title`) and ASP.NET
  /// validation errors (`errors: {Field: [msg]}`).
  static String _messageFrom(http.Response response) {
    final fallback = 'La solicitud falló (${response.statusCode}).';
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map<String, dynamic>) {
        final errors = body['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
        }
        final message = body['error'] ?? body['message'] ?? body['detail'] ?? body['title'];
        if (message != null) return message.toString();
      }
    } catch (_) {
      // Non-JSON error body; keep the default message.
    }
    return fallback;
  }

  Future<dynamic> _decode(http.Response response, {required bool auth}) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } on FormatException {
        throw ApiException(response.statusCode, 'Respuesta inesperada del servidor.');
      }
    }

    if (response.statusCode == 401 && auth) {
      await _tokenStorage.clear();
      onUnauthorized?.call();
    }
    throw ApiException(response.statusCode, _messageFrom(response));
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query, bool auth = true}) async {
    final headers = await _headers(auth: auth);
    return _decode(await _send(() => _client.get(_uri(path, query), headers: headers)), auth: auth);
  }

  Future<dynamic> post(String path, {Object? body, bool auth = true}) async {
    final headers = await _headers(auth: auth);
    return _decode(
      await _send(() => _client.post(_uri(path),
          headers: headers, body: body == null ? null : jsonEncode(body))),
      auth: auth,
    );
  }

  Future<dynamic> put(String path, {Object? body, bool auth = true}) async {
    final headers = await _headers(auth: auth);
    return _decode(
      await _send(() => _client.put(_uri(path),
          headers: headers, body: body == null ? null : jsonEncode(body))),
      auth: auth,
    );
  }

  Future<dynamic> delete(String path, {bool auth = true}) async {
    final headers = await _headers(auth: auth);
    return _decode(await _send(() => _client.delete(_uri(path), headers: headers)), auth: auth);
  }

  /// For non-JSON responses (file downloads such as the CSV/PDF reports).
  Future<List<int>> getBytes(String path, {Map<String, dynamic>? query, bool auth = true}) async {
    final headers = await _headers(auth: auth);
    final response = await _send(() => _client.get(_uri(path, query), headers: headers));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401 && auth) {
        await _tokenStorage.clear();
        onUnauthorized?.call();
      }
      throw ApiException(response.statusCode, _messageFrom(response));
    }
    return response.bodyBytes;
  }
}
