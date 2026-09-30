import 'package:flowledger/models/category_step_template.dart';
import 'package:flowledger/models/client_default_category.dart';
import 'package:flowledger/models/closed_period_summary.dart';
import 'package:flowledger/models/model_converters.dart';
import 'package:flowledger/models/payment.dart';
import 'package:flowledger/models/payment_period.dart';
import 'package:flowledger/models/period_category.dart';
import 'package:flowledger/models/period_detail.dart';
import 'package:flowledger/models/period_with_totals.dart';
import 'package:flowledger/models/work_item.dart';
import 'package:flowledger/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class PaymentPeriodRepository {
  PaymentPeriodRepository({DatabaseHelper? databaseHelper, Uuid? uuid})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance,
        _uuid = uuid ?? const Uuid();

  final DatabaseHelper _databaseHelper;
  final Uuid _uuid;

  /// Creates a period with snapshots of the client's default categories in one
  /// transaction. Later changes to the defaults do not affect this period.
  Future<PaymentPeriod> createPaymentPeriodForClient(
    String clientId,
    DateTime startDate,
  ) async {
    final now = DateTime.now();
    final period = PaymentPeriod(
      id: _uuid.v4(),
      clientId: clientId,
      startDate: startDate,
      createdAt: now,
      updatedAt: now,
    );
    final db = await _databaseHelper.database;

    await db.transaction((transaction) async {
      await transaction.insert(
        'payment_periods',
        period.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      await _copyDefaultCategoriesToPeriod(
        transaction,
        clientId: clientId,
        paymentPeriodId: period.id,
        copiedAt: now,
      );
    });

    return period;
  }

  Future<void> _copyDefaultCategoriesToPeriod(
    DatabaseExecutor executor, {
    required String clientId,
    required String paymentPeriodId,
    required DateTime copiedAt,
    bool verifyPeriod = false,
  }) async {
    if (verifyPeriod) {
      final periods = await executor.query(
        'payment_periods',
        columns: ['id'],
        where: 'id = ? AND client_id = ? AND deleted_at IS NULL',
        whereArgs: [paymentPeriodId, clientId],
        limit: 1,
      );
      if (periods.isEmpty) {
        throw StateError('Period not found.');
      }
    }

    final snapshots = await executor.query(
      'period_categories',
      columns: ['id'],
      where: 'payment_period_id = ? AND deleted_at IS NULL',
      whereArgs: [paymentPeriodId],
      limit: 1,
    );
    if (snapshots.isNotEmpty) {
      throw StateError('Category snapshots already exist for this period.');
    }

    final templates = await executor.query(
      'client_default_categories',
      where: 'client_id = ? AND is_active = 1 AND deleted_at IS NULL',
      whereArgs: [clientId],
      orderBy: 'name COLLATE NOCASE',
    );

    for (final row in templates) {
      final template = ClientDefaultCategory.fromMap(row);
      final snapshot = PeriodCategory(
        id: _uuid.v4(),
        clientId: clientId,
        paymentPeriodId: paymentPeriodId,
        sourceDefaultCategoryId: template.id,
        name: template.name,
        priceSnapshot: template.price,
        createdAt: copiedAt,
        updatedAt: copiedAt,
      );
      await executor.insert('period_categories', snapshot.toMap());
      await _copyDefaultStepsToPeriodCategory(
        executor,
        clientId: clientId,
        paymentPeriodId: paymentPeriodId,
        defaultCategoryId: template.id,
        periodCategoryId: snapshot.id,
        copiedAt: copiedAt,
      );
    }
  }

  Future<void> insert(PaymentPeriod period) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'payment_periods',
      period.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<PaymentPeriod?> getOpenForClient(String clientId) async {
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery(
      '''
        SELECT payment_periods.*
        FROM payment_periods
        INNER JOIN clients ON clients.id = payment_periods.client_id
        WHERE payment_periods.client_id = ?
          AND payment_periods.status = 'open'
          AND payment_periods.deleted_at IS NULL
          AND clients.is_active = 1
          AND clients.deleted_at IS NULL
        LIMIT 1
      ''',
      [clientId],
    );
    return rows.isEmpty ? null : PaymentPeriod.fromMap(rows.single);
  }

  Future<PaymentPeriod?> getOpenPeriodForClient(String clientId) =>
      getOpenForClient(clientId);

  /// Opens a new period with category snapshots if the client has none open.
  Future<PaymentPeriod> ensureOpenPeriodForClient(String clientId) async {
    await _ensureActiveClientExists(clientId);
    final existing = await getOpenForClient(clientId);
    if (existing != null) {
      return existing;
    }
    return createPaymentPeriodForClient(clientId, DateTime.now());
  }

  /// Fills an open period that has no category snapshots yet. Existing
  /// snapshots are never updated.
  Future<PaymentPeriod> ensurePeriodCategoriesForOpenPeriod(
      String clientId) async {
    final period = await ensureOpenPeriodForClient(clientId);
    final db = await _databaseHelper.database;
    await db.transaction((transaction) async {
      final snapshots = await transaction.query(
        'period_categories',
        columns: ['id'],
        where: 'payment_period_id = ? AND deleted_at IS NULL',
        whereArgs: [period.id],
        limit: 1,
      );
      if (snapshots.isEmpty) {
        await _copyDefaultCategoriesToPeriod(
          transaction,
          clientId: clientId,
          paymentPeriodId: period.id,
          copiedAt: DateTime.now(),
          verifyPeriod: true,
        );
      }
    });
    return period;
  }

  Future<List<PeriodCategory>> getPeriodCategories(
      String paymentPeriodId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'period_categories',
      where: 'payment_period_id = ? AND deleted_at IS NULL',
      whereArgs: [paymentPeriodId],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(PeriodCategory.fromMap).toList();
  }

  Future<List<PeriodCategory>> getOpenPeriodCategoriesForClient(
      String clientId) async {
    await ensurePeriodCategoriesForOpenPeriod(clientId);
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery(
      '''
        SELECT period_categories.*
        FROM period_categories
        INNER JOIN payment_periods
          ON payment_periods.id = period_categories.payment_period_id
        WHERE payment_periods.client_id = ?
          AND payment_periods.status = 'open'
          AND payment_periods.deleted_at IS NULL
          AND period_categories.deleted_at IS NULL
        ORDER BY period_categories.name COLLATE NOCASE
      ''',
      [clientId],
    );
    return rows.map(PeriodCategory.fromMap).toList();
  }

  /// Adds a new default category to the open period only. Closed periods and
  /// existing snapshots are not touched.
  Future<void> addDefaultCategorySnapshotToOpenPeriod(
    ClientDefaultCategory category,
  ) async {
    final period = await ensureOpenPeriodForClient(category.clientId);
    final db = await _databaseHelper.database;
    await db.transaction((transaction) async {
      final existing = await transaction.query(
        'period_categories',
        columns: ['id'],
        where:
            'payment_period_id = ? AND source_default_category_id = ? AND deleted_at IS NULL',
        whereArgs: [period.id, category.id],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        return;
      }

      final now = DateTime.now();
      final snapshot = PeriodCategory(
        id: _uuid.v4(),
        clientId: category.clientId,
        paymentPeriodId: period.id,
        sourceDefaultCategoryId: category.id,
        name: category.name,
        priceSnapshot: category.price,
        createdAt: now,
        updatedAt: now,
      );
      await transaction.insert('period_categories', snapshot.toMap());
      await _copyDefaultStepsToPeriodCategory(
        transaction,
        clientId: category.clientId,
        paymentPeriodId: period.id,
        defaultCategoryId: category.id,
        periodCategoryId: snapshot.id,
        copiedAt: now,
      );
    });
  }

  Future<List<ClosedPeriodSummary>> getClosedPeriodsWithTotals(
      String clientId) async {
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery(
      '''
        SELECT
          payment_periods.*,
          COALESCE((
            SELECT SUM(work_items.total_price)
            FROM work_items
            WHERE work_items.payment_period_id = payment_periods.id
              AND work_items.deleted_at IS NULL
              AND work_items.status = 'completed'
          ), 0) AS total_work_amount,
          COALESCE((
            SELECT SUM(payments.amount)
            FROM payments
            WHERE payments.payment_period_id = payment_periods.id
              AND payments.deleted_at IS NULL
          ), 0) AS payment_amount,
          (
            SELECT COUNT(*)
            FROM work_items
            WHERE work_items.payment_period_id = payment_periods.id
              AND work_items.deleted_at IS NULL
              AND work_items.status = 'completed'
          ) AS work_item_count
        FROM payment_periods
        WHERE payment_periods.client_id = ?
          AND payment_periods.status = 'closed'
          AND payment_periods.deleted_at IS NULL
        ORDER BY payment_periods.end_date DESC, payment_periods.start_date DESC
      ''',
      [clientId],
    );
    return rows
        .map(
          (row) => ClosedPeriodSummary(
            period: PaymentPeriod.fromMap(row),
            totalWorkAmount: (row['total_work_amount']! as num).toDouble(),
            paymentAmount: (row['payment_amount']! as num).toDouble(),
            workItemCount: (row['work_item_count']! as num).toInt(),
          ),
        )
        .toList();
  }

  /// Soft-deletes the period. Deleting the open period opens a new one in the
  /// same transaction.
  Future<void> softDeletePaymentPeriod(String paymentPeriodId) async {
    final db = await _databaseHelper.database;
    await db.transaction((transaction) async {
      final rows = await transaction.query(
        'payment_periods',
        where: 'id = ? AND deleted_at IS NULL',
        whereArgs: [paymentPeriodId],
        limit: 1,
      );
      if (rows.isEmpty) {
        throw StateError('Period not found or already deleted.');
      }
      final period = PaymentPeriod.fromMap(rows.single);
      final now = DateTime.now();
      final affected = await transaction.update(
        'payment_periods',
        {'deleted_at': isoDate(now), 'updated_at': isoDate(now)},
        where: 'id = ? AND deleted_at IS NULL',
        whereArgs: [paymentPeriodId],
      );
      if (affected != 1) {
        throw StateError('Could not delete the period.');
      }
      if (period.status == PaymentPeriodStatus.open) {
        final replacement = PaymentPeriod(
          id: _uuid.v4(),
          clientId: period.clientId,
          startDate: now,
          createdAt: now,
          updatedAt: now,
        );
        await transaction.insert('payment_periods', replacement.toMap());
        await _copyDefaultCategoriesToPeriod(
          transaction,
          clientId: period.clientId,
          paymentPeriodId: replacement.id,
          copiedAt: now,
        );
      }
    });
  }

  Future<List<PeriodWithTotals>> getAllPeriodsWithTotals() =>
      _getPeriodsWithTotals();

  Future<List<PeriodWithTotals>> getPeriodsForClientWithTotals(
          String clientId) =>
      _getPeriodsWithTotals(clientId: clientId);

  Future<List<PeriodWithTotals>> _getPeriodsWithTotals(
      {String? clientId}) async {
    final db = await _databaseHelper.database;
    final where = <String>[
      'payment_periods.deleted_at IS NULL',
      'clients.deleted_at IS NULL',
    ];
    final args = <Object?>[];
    if (clientId != null) {
      where.add('payment_periods.client_id = ?');
      args.add(clientId);
    }
    final rows = await db.rawQuery(
      '''
        SELECT
          payment_periods.*,
          clients.name AS client_name,
          COALESCE((
            SELECT SUM(work_items.total_price)
            FROM work_items
            WHERE work_items.payment_period_id = payment_periods.id
              AND work_items.deleted_at IS NULL
              AND work_items.status = 'completed'
          ), 0) AS total_work_amount,
          COALESCE((
            SELECT SUM(payments.amount)
            FROM payments
            WHERE payments.payment_period_id = payment_periods.id
              AND payments.deleted_at IS NULL
          ), 0) AS payment_amount,
          (
            SELECT COUNT(*) FROM work_items
            WHERE work_items.payment_period_id = payment_periods.id
              AND work_items.deleted_at IS NULL
              AND work_items.status = 'completed'
          ) AS work_item_count
        FROM payment_periods
        INNER JOIN clients ON clients.id = payment_periods.client_id
        WHERE ${where.join(' AND ')}
        ORDER BY clients.name COLLATE NOCASE, payment_periods.start_date DESC
      ''',
      args,
    );
    return rows.map(_periodWithTotalsFromRow).toList();
  }

  Future<PeriodDetail?> getPeriodDetail(String paymentPeriodId) async {
    final periods = await _getPeriodsWithTotalsById(paymentPeriodId);
    if (periods.isEmpty) {
      return null;
    }
    final db = await _databaseHelper.database;
    final categories = await getPeriodCategories(paymentPeriodId);
    final workItems = await _getWorkItemsForPeriod(db, paymentPeriodId);
    final payments = await _getPaymentsForPeriod(db, paymentPeriodId);
    return PeriodDetail(
      summary: periods.single,
      categories: categories,
      workItems: workItems,
      payments: payments,
    );
  }

  Future<List<PeriodWithTotals>> _getPeriodsWithTotalsById(
      String paymentPeriodId) async {
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery(
      '''
        SELECT
          payment_periods.*,
          clients.name AS client_name,
          COALESCE((SELECT SUM(total_price) FROM work_items
            WHERE payment_period_id = payment_periods.id AND deleted_at IS NULL
              AND status = 'completed'), 0)
            AS total_work_amount,
          COALESCE((SELECT SUM(amount) FROM payments
            WHERE payment_period_id = payment_periods.id AND deleted_at IS NULL), 0)
            AS payment_amount,
          (SELECT COUNT(*) FROM work_items
            WHERE payment_period_id = payment_periods.id AND deleted_at IS NULL
              AND status = 'completed')
            AS work_item_count
        FROM payment_periods
        INNER JOIN clients ON clients.id = payment_periods.client_id
        WHERE payment_periods.id = ?
          AND payment_periods.deleted_at IS NULL
          AND clients.deleted_at IS NULL
      ''',
      [paymentPeriodId],
    );
    return rows.map(_periodWithTotalsFromRow).toList();
  }

  Future<List<WorkItem>> _getWorkItemsForPeriod(
      Database db, String paymentPeriodId) async {
    final rows = await db.query(
      'work_items',
      where: 'payment_period_id = ? AND deleted_at IS NULL',
      whereArgs: [paymentPeriodId],
      orderBy: 'completed_at DESC, created_at DESC',
    );
    return rows.map(WorkItem.fromMap).toList();
  }

  Future<List<Payment>> _getPaymentsForPeriod(
      Database db, String paymentPeriodId) async {
    final rows = await db.query(
      'payments',
      where: 'payment_period_id = ? AND deleted_at IS NULL',
      whereArgs: [paymentPeriodId],
      orderBy: 'paid_at DESC, created_at DESC',
    );
    return rows.map(Payment.fromMap).toList();
  }

  PeriodWithTotals _periodWithTotalsFromRow(Map<String, Object?> row) =>
      PeriodWithTotals(
        period: PaymentPeriod.fromMap(row),
        clientName: row['client_name']! as String,
        totalWorkAmount: (row['total_work_amount']! as num).toDouble(),
        paymentAmount: (row['payment_amount']! as num).toDouble(),
        workItemCount: (row['work_item_count']! as num).toInt(),
      );

  Future<void> _ensureActiveClientExists(String clientId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'clients',
      columns: ['id'],
      where: 'id = ? AND is_active = 1 AND deleted_at IS NULL',
      whereArgs: [clientId],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw StateError('Client not found.');
    }
  }

  Future<void> _copyDefaultStepsToPeriodCategory(
    DatabaseExecutor executor, {
    required String clientId,
    required String paymentPeriodId,
    required String defaultCategoryId,
    required String periodCategoryId,
    required DateTime copiedAt,
  }) async {
    final rows = await executor.query(
      'client_default_category_steps',
      where:
          'client_id = ? AND default_category_id = ? AND is_active = 1 AND deleted_at IS NULL',
      whereArgs: [clientId, defaultCategoryId],
      orderBy: 'sort_order ASC, created_at ASC',
    );
    for (final row in rows) {
      final template = ClientDefaultCategoryStep.fromMap(row);
      final snapshot = PeriodCategoryStep(
        id: _uuid.v4(),
        clientId: clientId,
        paymentPeriodId: paymentPeriodId,
        periodCategoryId: periodCategoryId,
        sourceDefaultStepId: template.id,
        title: template.title,
        sortOrder: template.sortOrder,
        createdAt: copiedAt,
        updatedAt: copiedAt,
      );
      await executor.insert(
        'period_category_steps',
        snapshot.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }
  }
}
