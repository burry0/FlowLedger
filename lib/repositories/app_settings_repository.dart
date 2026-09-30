import 'package:flowledger/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class AppSettingsRepository {
  AppSettingsRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  static const themeModeKey = 'theme_mode';
  static const languageCodeKey = 'language_code';
  static const currencyCodeKey = 'currency_code';
  final DatabaseHelper _databaseHelper;

  Future<String?> getValue(String key) async {
    final db = await _databaseHelper.database;
    final rows = await db.query('app_settings',
        columns: ['value'], where: 'key = ?', whereArgs: [key]);
    return rows.isEmpty ? null : rows.single['value'] as String?;
  }

  Future<void> setValue(String key, String value) async {
    final db = await _databaseHelper.database;
    await db.insert('app_settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
