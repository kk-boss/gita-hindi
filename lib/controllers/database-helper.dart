import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as Path;

class DatabaseHelper {
  static Database _db;
  static const String DATABASE_FILE_NAME = 'geeta.sqlite';
  static const String MAIN_TABLE_NAME = 'githa';
  static const String AUDIO_TABLE_NAME = 'audio';

  static Future<String> getDatabasePath() async {
    return Path.join(await getDatabasesPath(), DATABASE_FILE_NAME);
  }

  static Future<Database> initDatabase() async {
    if (_db == null || !_db.isOpen) {
      _db = await openDatabase(
        await getDatabasePath(),
      );
    }
    return _db;
  }

  static void disposeDatabase() {
    _db?.close();
  }
}
