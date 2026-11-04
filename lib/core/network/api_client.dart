import 'dart:convert';

import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Thin wrapper over `package:http` for MindFlow's backend: injects the
/// Bearer JWT, encodes/decodes JSON and surfaces failures as
/// [ApiException]. Routes always carry the `/api/v1` prefix the deployed
/// Railway backend expects (see the Workday v2 design handoff's routing
/// note).
class ApiClient {
  static const baseUrl =
      'https://powerful-wholeness-production.up.railway.app/api/v1';

  final http.Client _client;
  final TokenStorage _tokenStorage;

  ApiClient({http.Client? client, required TokenStorage tokenStorage})
      : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage;

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

  dynamic _decode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    }

    String message = 'Request failed (${response.statusCode}).';
    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is Map<String, dynamic>) {
        message = (body['error'] ?? body['detail'] ?? body['title'] ?? message)
            .toString();
      }
    } catch (_) {
      // Non-JSON error body; keep the default message.
    }
    throw ApiException(response.statusCode, message);
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query, bool auth = true}) async {
    final response =
        await _client.get(_uri(path, query), headers: await _headers(auth: auth));
    return _decode(response);
  }

  Future<dynamic> post(String path, {Object? body, bool auth = true}) async {
    final response = await _client.post(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> put(String path, {Object? body, bool auth = true}) async {
    final response = await _client.put(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> patch(String path, {Object? body, bool auth = true}) async {
    final response = await _client.patch(
      _uri(path),
      headers: await _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> delete(String path, {bool auth = true}) async {
    final response =
        await _client.delete(_uri(path), headers: await _headers(auth: auth));
    return _decode(response);
  }

  /// For non-JSON responses (file downloads such as the CSV/PDF reports).
  Future<List<int>> getBytes(String path, {Map<String, dynamic>? query, bool auth = true}) async {
    final response =
        await _client.get(_uri(path, query), headers: await _headers(auth: auth));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, 'Request failed (${response.statusCode}).');
    }
    return response.bodyBytes;
  }
}
