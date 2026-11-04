import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Small local-only preferences store (dark mode, language, and the two
/// device-only Settings toggles that have no backend concept). Reuses
/// [FlutterSecureStorage] instead of adding shared_preferences as a
/// second storage dependency.
class LocalPrefs {
  final FlutterSecureStorage _storage;
  LocalPrefs({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  Future<void> setBool(String key, bool value) => _storage.write(key: key, value: value.toString());

  Future<bool?> getBool(String key) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    return value == 'true';
  }

  Future<void> setString(String key, String value) => _storage.write(key: key, value: value);

  Future<String?> getString(String key) => _storage.read(key: key);
}
