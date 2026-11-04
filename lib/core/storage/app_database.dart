import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Local SQLite cache, mirroring the role `SQLite` plays in the Android
/// (Kotlin/Compose) app: a resilience cache so the user never loses a
/// registro if the backend is unreachable. Each feature adds its own
/// tables to [_onCreate]/[_onUpgrade] as it needs local persistence.
class AppDatabase {
  static const _version = 1;

  Future<Database>? _database;
  Future<Database> get database => _database ??= _openDatabase();

  Future<Database> _openDatabase() async {
    final path = join(await getDatabasesPath(), 'mindflow_workday.db');
    return openDatabase(
      path,
      version: _version,
      onCreate: (db, version) async {},
    );
  }
}
