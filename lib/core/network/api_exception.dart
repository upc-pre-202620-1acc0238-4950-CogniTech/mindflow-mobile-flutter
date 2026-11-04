/// Thrown when a backend call fails, carrying the HTTP status and the
/// server's error message (field `error` on MindFlow's error responses).
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
