import 'package:flowledger/models/period_category.dart';
import 'package:flowledger/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class PeriodCategoryRepository {
  PeriodCategoryRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<void> insert(PeriodCategory category) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'period_categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<List<PeriodCategory>> getForPeriod(String paymentPeriodId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'period_categories',
      where: 'payment_period_id = ? AND deleted_at IS NULL',
      whereArgs: [paymentPeriodId],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(PeriodCategory.fromMap).toList();
  }
}
