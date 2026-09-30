import 'package:flowledger/models/client_open_balance.dart';
import 'package:flowledger/models/model_converters.dart';
import 'package:flowledger/services/database_helper.dart';

class DashboardRepository {
  DashboardRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  /// Work total of all open periods minus the payments in those periods.
  Future<double> getTotalUnpaidAcrossOpenPeriods() async {
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery('''
      SELECT
        COALESCE((
          SELECT SUM(work_items.total_price)
          FROM work_items
          INNER JOIN payment_periods
            ON payment_periods.id = work_items.payment_period_id
          INNER JOIN clients ON clients.id = payment_periods.client_id
          WHERE payment_periods.status = 'open'
            AND payment_periods.deleted_at IS NULL
            AND work_items.deleted_at IS NULL
            AND clients.deleted_at IS NULL
        ), 0) -
        COALESCE((
          SELECT SUM(payments.amount)
          FROM payments
          INNER JOIN payment_periods
            ON payment_periods.id = payments.payment_period_id
          INNER JOIN clients ON clients.id = payment_periods.client_id
          WHERE payment_periods.status = 'open'
            AND payment_periods.deleted_at IS NULL
            AND payments.deleted_at IS NULL
            AND clients.deleted_at IS NULL
        ), 0) AS total_unpaid
    ''');
    return (rows.single['total_unpaid']! as num).toDouble();
  }

  Future<int> getActiveClientCount() async {
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery('''
      SELECT COUNT(*) AS active_client_count
      FROM clients
      WHERE is_active = 1 AND deleted_at IS NULL
    ''');
    return (rows.single['active_client_count']! as num).toInt();
  }

  Future<int> getCompletedWorkItemCountForMonth(int year, int month) async {
    final range = _monthRange(year, month);
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery(
      '''
        SELECT COUNT(*) AS work_item_count
        FROM work_items
        INNER JOIN clients ON clients.id = work_items.client_id
        INNER JOIN payment_periods ON payment_periods.id = work_items.payment_period_id
        WHERE work_items.status = 'completed'
          AND work_items.completed_at >= ?
          AND work_items.completed_at < ?
          AND work_items.deleted_at IS NULL
          AND clients.deleted_at IS NULL
          AND payment_periods.deleted_at IS NULL
      ''',
      [isoDate(range.start), isoDate(range.end)],
    );
    return (rows.single['work_item_count']! as num).toInt();
  }

  Future<double> getPaidTotalForMonth(int year, int month) async {
    final range = _monthRange(year, month);
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery(
      '''
        SELECT COALESCE(SUM(amount), 0) AS paid_total
        FROM payments
        INNER JOIN clients ON clients.id = payments.client_id
        INNER JOIN payment_periods ON payment_periods.id = payments.payment_period_id
        WHERE payments.paid_at >= ?
          AND payments.paid_at < ?
          AND payments.deleted_at IS NULL
          AND clients.deleted_at IS NULL
          AND payment_periods.deleted_at IS NULL
      ''',
      [isoDate(range.start), isoDate(range.end)],
    );
    return (rows.single['paid_total']! as num).toDouble();
  }

  Future<List<ClientOpenBalance>> getClientsWithOpenBalances() async {
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery('''
      SELECT
        clients.id AS client_id,
        clients.name AS client_name,
        COALESCE((
          SELECT SUM(work_items.total_price)
          FROM work_items
          INNER JOIN payment_periods
            ON payment_periods.id = work_items.payment_period_id
          WHERE payment_periods.client_id = clients.id
            AND payment_periods.status = 'open'
            AND payment_periods.deleted_at IS NULL
            AND work_items.deleted_at IS NULL
        ), 0) -
        COALESCE((
          SELECT SUM(payments.amount)
          FROM payments
          INNER JOIN payment_periods
            ON payment_periods.id = payments.payment_period_id
          WHERE payment_periods.client_id = clients.id
            AND payment_periods.status = 'open'
            AND payment_periods.deleted_at IS NULL
            AND payments.deleted_at IS NULL
        ), 0) AS open_period_total,
        (
          SELECT COUNT(*)
          FROM work_items
          INNER JOIN payment_periods
            ON payment_periods.id = work_items.payment_period_id
          WHERE payment_periods.client_id = clients.id
            AND payment_periods.status = 'open'
            AND payment_periods.deleted_at IS NULL
            AND work_items.deleted_at IS NULL
        ) AS work_item_count
      FROM clients
      WHERE clients.is_active = 1
        AND clients.deleted_at IS NULL
      ORDER BY clients.name COLLATE NOCASE
    ''');

    return rows
        .map(
          (row) => ClientOpenBalance(
            clientId: row['client_id']! as String,
            clientName: row['client_name']! as String,
            openPeriodTotal: (row['open_period_total']! as num).toDouble(),
            workItemCount: (row['work_item_count']! as num).toInt(),
          ),
        )
        .where((balance) => balance.openPeriodTotal > 0)
        .toList();
  }

  _MonthRange _monthRange(int year, int month) {
    if (month < 1 || month > 12) {
      throw ArgumentError.value(
          month, 'month', 'Month must be between 1 and 12.');
    }
    return _MonthRange(
      start: DateTime(year, month),
      end: DateTime(year, month + 1),
    );
  }
}

class _MonthRange {
  const _MonthRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}
