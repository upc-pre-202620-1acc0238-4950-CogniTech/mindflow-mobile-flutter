import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the JWT issued by `POST /api/v1/users/sign-in` (or
/// `/google-auth`) in the platform's secure storage (Keychain/Keystore).
class TokenStorage {
  static const _tokenKey = 'mindflow_jwt';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> save(String token) => _storage.write(key: _tokenKey, value: token);

  Future<String?> read() => _storage.read(key: _tokenKey);

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
