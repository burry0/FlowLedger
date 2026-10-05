import 'package:flowledger/models/category_step_template.dart';
import 'package:flowledger/models/client_default_category.dart';
import 'package:flowledger/models/model_converters.dart';
import 'package:flowledger/models/payment.dart';
import 'package:flowledger/models/payment_allocation.dart';
import 'package:flowledger/models/payment_period.dart';
import 'package:flowledger/models/period_category.dart';
import 'package:flowledger/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class PaymentRepository {
  PaymentRepository({DatabaseHelper? databaseHelper, Uuid? uuid})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance,
        _uuid = uuid ?? const Uuid();

  final DatabaseHelper _databaseHelper;
  final Uuid _uuid;

  /// Records the payment, closes the open period and opens a new one from the
  /// current default categories.
  Future<Payment?> recordPaymentAndStartNewPeriod(
    String clientId,
    double amount,
    DateTime paidAt,
    String? note,
  ) async {
    if (amount < 0) {
      throw ArgumentError.value(
          amount, 'amount', 'Payment amount cannot be negative.');
    }

    final normalizedNote = note?.trim();
    final paymentNote = normalizedNote == null || normalizedNote.isEmpty
        ? null
        : normalizedNote;
    final db = await _databaseHelper.database;
    return db.transaction((transaction) async {
      final periods = await transaction.query(
        'payment_periods',
        columns: ['id'],
        where: "client_id = ? AND status = 'open' AND deleted_at IS NULL",
        whereArgs: [clientId],
        limit: 1,
      );
      if (periods.isEmpty) {
        throw StateError('The client has no open period.');
      }

      final now = DateTime.now();
      final currentPeriodId = periods.single['id']! as String;
      await _ensureNoInProgressWorkItems(transaction, currentPeriodId);
      final payment = amount == 0
          ? null
          : Payment(
              id: _uuid.v4(),
              clientId: clientId,
              paymentPeriodId: currentPeriodId,
              amount: amount,
              paidAt: paidAt,
              note: paymentNote,
              createdAt: now,
              updatedAt: now,
            );
      if (payment != null) {
        await transaction.insert(
          'payments',
          payment.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
      await _closePaymentPeriod(transaction, currentPeriodId, paidAt, now);
      await _createNewOpenPeriodWithCategorySnapshots(
        transaction,
        clientId: clientId,
        startDate: paidAt,
        createdAt: now,
      );
      return payment;
    });
  }

  /// Records a payment in the open period without closing it. With
  /// [workItemIds], those work items are marked as paid by this payment; they
  /// must be completed, unpaid work of the open period and [amount] must equal
  /// their total.
  Future<Payment> recordPartialPaymentForOpenPeriod(
    String clientId,
    double amount,
    DateTime paidAt,
    String? note, {
    List<String> workItemIds = const [],
  }) async {
    if (amount <= 0) {
      throw ArgumentError.value(
          amount, 'amount', 'Partial payment must be greater than zero.');
    }
    final selectedIds = workItemIds.toSet();

    final normalizedNote = note?.trim();
    final paymentNote = normalizedNote == null || normalizedNote.isEmpty
        ? null
        : normalizedNote;
    final db = await _databaseHelper.database;
    return db.transaction((transaction) async {
      final periods = await transaction.query(
        'payment_periods',
        columns: ['id'],
        where: "client_id = ? AND status = 'open' AND deleted_at IS NULL",
        whereArgs: [clientId],
        limit: 1,
      );
      if (periods.isEmpty) {
        throw StateError('The client has no open period.');
      }

      final periodId = periods.single['id']! as String;
      final itemTotals = await _unpaidCompletedWorkTotals(
        transaction,
        periodId,
        selectedIds,
      );
      if (selectedIds.isNotEmpty) {
        final selectedTotal =
            itemTotals.values.fold<double>(0, (sum, total) => sum + total);
        if ((selectedTotal - amount).abs() >= _amountTolerance) {
          throw ArgumentError.value(amount, 'amount',
              'Amount must equal the total of the selected work.');
        }
      }

      final now = DateTime.now();
      final payment = Payment(
        id: _uuid.v4(),
        clientId: clientId,
        paymentPeriodId: periodId,
        amount: amount,
        paidAt: paidAt,
        note: paymentNote,
        createdAt: now,
        updatedAt: now,
      );
      await transaction.insert(
        'payments',
        payment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      for (final entry in itemTotals.entries) {
        final allocation = PaymentAllocation(
          id: _uuid.v4(),
          paymentId: payment.id,
          workItemId: entry.key,
          amount: entry.value,
          createdAt: now,
          updatedAt: now,
        );
        await transaction.insert(
          'payment_allocations',
          allocation.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
      }
      return payment;
    });
  }

  /// Totals of the [workItemIds] by id. Throws unless every one is completed,
  /// unpaid work in [paymentPeriodId].
  Future<Map<String, double>> _unpaidCompletedWorkTotals(
    DatabaseExecutor executor,
    String paymentPeriodId,
    Set<String> workItemIds,
  ) async {
    if (workItemIds.isEmpty) {
      return const {};
    }
    final placeholders = List.filled(workItemIds.length, '?').join(', ');
    final rows = await executor.rawQuery(
      '''
        SELECT work_items.id, work_items.total_price
        FROM work_items
        WHERE work_items.id IN ($placeholders)
          AND work_items.payment_period_id = ?
          AND work_items.status = 'completed'
          AND work_items.deleted_at IS NULL
          AND NOT EXISTS (
            SELECT 1 FROM payment_allocations
            WHERE payment_allocations.work_item_id = work_items.id
              AND payment_allocations.deleted_at IS NULL
          )
      ''',
      [...workItemIds, paymentPeriodId],
    );
    if (rows.length != workItemIds.length) {
      throw StateError(
        'Only completed, unpaid work in the open period can be selected.',
      );
    }
    return {
      for (final row in rows)
        row['id']! as String: (row['total_price']! as num).toDouble(),
    };
  }

  /// Work items of [paymentPeriodId] that were marked as paid, with the
  /// payment that covers them.
  Future<PeriodPaidWork> getPaidWorkForPeriod(String paymentPeriodId) async {
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery(
      '''
        SELECT
          payment_allocations.work_item_id,
          payment_allocations.payment_id,
          work_items.title,
          payments.paid_at
        FROM payment_allocations
        INNER JOIN payments ON payments.id = payment_allocations.payment_id
        INNER JOIN work_items
          ON work_items.id = payment_allocations.work_item_id
        WHERE payments.payment_period_id = ?
          AND payment_allocations.deleted_at IS NULL
          AND payments.deleted_at IS NULL
          AND work_items.deleted_at IS NULL
        ORDER BY work_items.title COLLATE NOCASE
      ''',
      [paymentPeriodId],
    );
    return PeriodPaidWork([
      for (final row in rows)
        PaidWorkItem(
          workItemId: row['work_item_id']! as String,
          workItemTitle: row['title']! as String,
          paymentId: row['payment_id']! as String,
          paidAt: dateFromDatabase(row['paid_at']),
        ),
    ]);
  }

  /// Rounding slack when comparing money totals stored as doubles.
  static const _amountTolerance = 0.005;

  Future<void> _closePaymentPeriod(
    DatabaseExecutor executor,
    String paymentPeriodId,
    DateTime endDate,
    DateTime updatedAt,
  ) async {
    await _ensureNoInProgressWorkItems(executor, paymentPeriodId);
    final affected = await executor.update(
      'payment_periods',
      {
        'status': PaymentPeriodStatus.closed.name,
        'end_date': isoDate(endDate),
        'updated_at': isoDate(updatedAt),
      },
      where: "id = ? AND status = 'open' AND deleted_at IS NULL",
      whereArgs: [paymentPeriodId],
    );
    if (affected != 1) {
      throw StateError('Could not close the open period.');
    }
  }

  Future<PaymentPeriod> _createNewOpenPeriodWithCategorySnapshots(
    DatabaseExecutor executor, {
    required String clientId,
    required DateTime startDate,
    required DateTime createdAt,
  }) async {
    final period = PaymentPeriod(
      id: _uuid.v4(),
      clientId: clientId,
      startDate: startDate,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
    await executor.insert(
      'payment_periods',
      period.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

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
        paymentPeriodId: period.id,
        sourceDefaultCategoryId: template.id,
        name: template.name,
        priceSnapshot: template.price,
        createdAt: createdAt,
        updatedAt: createdAt,
      );
      await executor.insert('period_categories', snapshot.toMap());
      await _copyDefaultStepsToPeriodCategory(
        executor,
        clientId: clientId,
        paymentPeriodId: period.id,
        defaultCategoryId: template.id,
        periodCategoryId: snapshot.id,
        copiedAt: createdAt,
      );
    }
    return period;
  }

  Future<List<Payment>> getPaymentHistoryForClient(String clientId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'payments',
      where: 'client_id = ? AND deleted_at IS NULL',
      whereArgs: [clientId],
      orderBy: 'paid_at DESC, created_at DESC',
    );
    return rows.map(Payment.fromMap).toList();
  }

  Future<List<Payment>> getForPeriod(String paymentPeriodId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'payments',
      where: 'payment_period_id = ? AND deleted_at IS NULL',
      whereArgs: [paymentPeriodId],
      orderBy: 'paid_at DESC',
    );
    return rows.map(Payment.fromMap).toList();
  }

  Future<List<Payment>> getPaymentsForPeriod(String paymentPeriodId) =>
      getForPeriod(paymentPeriodId);

  Future<void> _ensureNoInProgressWorkItems(
    DatabaseExecutor executor,
    String paymentPeriodId,
  ) async {
    final rows = await executor.rawQuery(
      '''
        SELECT COUNT(*) AS count
        FROM work_items
        WHERE payment_period_id = ?
          AND status = 'in_progress'
          AND deleted_at IS NULL
      ''',
      [paymentPeriodId],
    );
    final count = (rows.single['count']! as num).toInt();
    if (count > 0) {
      throw StateError(
        'Complete or delete in-progress work before closing the period.',
      );
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
