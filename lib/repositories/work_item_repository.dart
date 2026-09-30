import 'package:flowledger/models/model_converters.dart';
import 'package:flowledger/models/payment_period.dart';
import 'package:flowledger/models/work_item.dart';
import 'package:flowledger/models/work_item_filters.dart';
import 'package:flowledger/models/work_item_step.dart';
import 'package:flowledger/models/work_item_with_client.dart';
import 'package:flowledger/repositories/payment_period_repository.dart';
import 'package:flowledger/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class WorkItemRepository {
  WorkItemRepository({DatabaseHelper? databaseHelper, Uuid? uuid})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance,
        _uuid = uuid ?? const Uuid();

  final DatabaseHelper _databaseHelper;
  final Uuid _uuid;

  Future<WorkItem> addWorkItemFromPeriodCategory(
    String periodCategoryId, {
    bool createAsCompleted = false,
  }) async {
    final db = await _databaseHelper.database;
    return db.transaction((transaction) async {
      final category =
          await _getOpenPeriodCategory(transaction, periodCategoryId);
      final now = DateTime.now();
      final status = createAsCompleted
          ? WorkItemStatus.completed
          : WorkItemStatus.inProgress;
      final workItem = WorkItem(
        id: _uuid.v4(),
        clientId: category.clientId,
        paymentPeriodId: category.paymentPeriodId,
        periodCategoryId: category.id,
        title: category.name,
        priceSnapshot: category.priceSnapshot,
        quantity: 1,
        totalPrice: category.priceSnapshot,
        status: status,
        completedAt: createAsCompleted ? now : null,
        createdAt: now,
        updatedAt: now,
      );
      await transaction.insert(
        'work_items',
        workItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      await _copyPeriodCategoryStepsToWorkItem(
        transaction,
        periodCategoryId: category.id,
        workItemId: workItem.id,
        copiedAt: now,
      );
      return workItem;
    });
  }

  Future<WorkItem> addCustomWorkItem(
    String clientId,
    String title,
    double price,
    double quantity,
    String? notes, {
    bool createAsCompleted = false,
  }) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Work title cannot be empty.');
    }
    if (price < 0) {
      throw ArgumentError.value(price, 'price', 'Price cannot be negative.');
    }
    if (quantity <= 0) {
      throw ArgumentError.value(
          quantity, 'quantity', 'Quantity must be greater than zero.');
    }

    final period = await PaymentPeriodRepository(
      databaseHelper: _databaseHelper,
    ).ensurePeriodCategoriesForOpenPeriod(clientId);
    final normalizedNotes = notes?.trim();
    final now = DateTime.now();
    final status = createAsCompleted
        ? WorkItemStatus.completed
        : WorkItemStatus.inProgress;
    final workItem = WorkItem(
      id: _uuid.v4(),
      clientId: clientId,
      paymentPeriodId: period.id,
      title: normalizedTitle,
      priceSnapshot: price,
      quantity: quantity,
      totalPrice: price * quantity,
      status: status,
      completedAt: createAsCompleted ? now : null,
      notes: normalizedNotes == null || normalizedNotes.isEmpty
          ? null
          : normalizedNotes,
      createdAt: now,
      updatedAt: now,
    );
    await insert(workItem);
    return workItem;
  }

  Future<WorkItem> create({
    required String clientId,
    required String paymentPeriodId,
    required String periodCategoryId,
    required String title,
    double quantity = 1,
    DateTime? completedAt,
    String? notes,
  }) async {
    final db = await _databaseHelper.database;
    final category = await _getOpenPeriodCategory(db, periodCategoryId);
    if (category.clientId != clientId ||
        category.paymentPeriodId != paymentPeriodId) {
      throw StateError(
          'The period category belongs to another client or period.');
    }

    final now = DateTime.now();
    final workItem = WorkItem(
      id: _uuid.v4(),
      clientId: clientId,
      paymentPeriodId: paymentPeriodId,
      periodCategoryId: periodCategoryId,
      title: title,
      priceSnapshot: category.priceSnapshot,
      quantity: quantity,
      totalPrice: category.priceSnapshot * quantity,
      status: completedAt == null
          ? WorkItemStatus.inProgress
          : WorkItemStatus.completed,
      completedAt: completedAt,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    await db.transaction((transaction) async {
      final category =
          await _getOpenPeriodCategory(transaction, periodCategoryId);
      if (category.clientId != clientId ||
          category.paymentPeriodId != paymentPeriodId ||
          workItem.priceSnapshot != category.priceSnapshot) {
        throw ArgumentError(
          'The work item must match a category of the open period.',
        );
      }
      await transaction.insert(
        'work_items',
        workItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      await _copyPeriodCategoryStepsToWorkItem(
        transaction,
        periodCategoryId: periodCategoryId,
        workItemId: workItem.id,
        copiedAt: now,
      );
    });
    return workItem;
  }

  Future<void> insert(WorkItem workItem) async {
    final periodCategoryId = workItem.periodCategoryId;
    if (periodCategoryId == null) {
      final db = await _databaseHelper.database;
      final period = await _getOpenPeriodForClient(db, workItem.clientId);
      if (period.id != workItem.paymentPeriodId) {
        throw ArgumentError(
          'One-off work must belong to the open period.',
        );
      }
      await db.insert('work_items', workItem.toMap(),
          conflictAlgorithm: ConflictAlgorithm.abort);
      return;
    }

    final db = await _databaseHelper.database;
    final category = await _getOpenPeriodCategory(db, periodCategoryId);
    if (category.clientId != workItem.clientId ||
        category.paymentPeriodId != workItem.paymentPeriodId ||
        workItem.priceSnapshot != category.priceSnapshot) {
      throw ArgumentError(
        'The work item must match a category of the open period.',
      );
    }
    await db.insert('work_items', workItem.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  /// Updates title, quantity, multiplier and notes. The unit price always comes
  /// from the item's own [WorkItem.priceSnapshot], never from the current
  /// category price. An empty [title] keeps the current one.
  Future<WorkItem> updateWorkItem(
    String workItemId, {
    String? title,
    required double quantity,
    double multiplier = 1,
    String? notes,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError.value(
          quantity, 'quantity', 'Quantity must be greater than zero.');
    }
    if (multiplier <= 0) {
      throw ArgumentError.value(
          multiplier, 'multiplier', 'Multiplier must be greater than zero.');
    }

    final normalizedTitle = title?.trim();
    final normalizedNotes = notes?.trim();
    final db = await _databaseHelper.database;
    return db.transaction((transaction) async {
      final current = await _getOpenWorkItem(transaction, workItemId);
      final updatedAt = DateTime.now();
      final newTitle = normalizedTitle == null || normalizedTitle.isEmpty
          ? current.title
          : normalizedTitle;
      final totalPrice = current.priceSnapshot * quantity * multiplier;
      final newNotes = normalizedNotes == null || normalizedNotes.isEmpty
          ? null
          : normalizedNotes;
      final affected = await transaction.update(
        'work_items',
        {
          'title': newTitle,
          'quantity': quantity,
          'multiplier': multiplier,
          'total_price': totalPrice,
          'notes': newNotes,
          'updated_at': isoDate(updatedAt),
        },
        where: 'id = ? AND deleted_at IS NULL',
        whereArgs: [workItemId],
      );
      if (affected != 1) {
        throw StateError('Could not update the work item.');
      }
      return WorkItem(
        id: current.id,
        clientId: current.clientId,
        paymentPeriodId: current.paymentPeriodId,
        periodCategoryId: current.periodCategoryId,
        title: newTitle,
        priceSnapshot: current.priceSnapshot,
        quantity: quantity,
        totalPrice: totalPrice,
        multiplier: multiplier,
        status: current.status,
        completedAt: current.completedAt,
        notes: newNotes,
        createdAt: current.createdAt,
        updatedAt: updatedAt,
        deletedAt: current.deletedAt,
      );
    });
  }

  /// Soft delete. Work in closed periods cannot be deleted.
  Future<void> softDeleteWorkItem(String workItemId) async {
    final db = await _databaseHelper.database;
    await db.transaction((transaction) async {
      await _getOpenWorkItem(transaction, workItemId);
      final now = isoDate(DateTime.now());
      final affected = await transaction.update(
        'work_items',
        {
          'updated_at': now,
          'deleted_at': now,
        },
        where: 'id = ? AND deleted_at IS NULL',
        whereArgs: [workItemId],
      );
      if (affected != 1) {
        throw StateError('Could not delete the work item.');
      }
    });
  }

  Future<List<WorkItemStep>> getStepsForWorkItem(String workItemId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'work_item_steps',
      where: 'work_item_id = ? AND deleted_at IS NULL',
      whereArgs: [workItemId],
      orderBy: 'sort_order ASC, created_at ASC',
    );
    return rows.map(WorkItemStep.fromMap).toList();
  }

  Future<void> updateWorkItemStepDone(
    String stepId, {
    required bool isDone,
  }) async {
    final db = await _databaseHelper.database;
    await db.transaction((transaction) async {
      final rows = await transaction.rawQuery(
        '''
          SELECT work_item_steps.id
          FROM work_item_steps
          INNER JOIN work_items
            ON work_items.id = work_item_steps.work_item_id
          INNER JOIN payment_periods
            ON payment_periods.id = work_items.payment_period_id
          WHERE work_item_steps.id = ?
            AND work_item_steps.deleted_at IS NULL
            AND work_items.deleted_at IS NULL
            AND payment_periods.status = 'open'
            AND payment_periods.deleted_at IS NULL
          LIMIT 1
        ''',
        [stepId],
      );
      if (rows.isEmpty) {
        throw StateError('Stage not found.');
      }
      final now = DateTime.now();
      final affected = await transaction.update(
        'work_item_steps',
        {
          'is_done': isDone ? 1 : 0,
          'completed_at': isDone ? isoDate(now) : null,
          'updated_at': isoDate(now),
        },
        where: 'id = ? AND deleted_at IS NULL',
        whereArgs: [stepId],
      );
      if (affected != 1) {
        throw StateError('Could not update the stage.');
      }
    });
  }

  Future<WorkItem> markWorkItemCompleted(String workItemId) async {
    final db = await _databaseHelper.database;
    return db.transaction((transaction) async {
      final current = await _getOpenWorkItem(transaction, workItemId);
      final now = DateTime.now();
      final affected = await transaction.update(
        'work_items',
        {
          'status': WorkItemStatus.completed.databaseValue,
          'completed_at': isoDate(now),
          'updated_at': isoDate(now),
        },
        where: 'id = ? AND deleted_at IS NULL',
        whereArgs: [workItemId],
      );
      if (affected != 1) {
        throw StateError('Could not complete the work item.');
      }
      return WorkItem(
        id: current.id,
        clientId: current.clientId,
        paymentPeriodId: current.paymentPeriodId,
        periodCategoryId: current.periodCategoryId,
        title: current.title,
        priceSnapshot: current.priceSnapshot,
        quantity: current.quantity,
        totalPrice: current.totalPrice,
        multiplier: current.multiplier,
        status: WorkItemStatus.completed,
        completedAt: now,
        notes: current.notes,
        createdAt: current.createdAt,
        updatedAt: now,
        deletedAt: current.deletedAt,
      );
    });
  }

  Future<List<WorkItem>> getWorkItemsForClientOpenPeriod(
      String clientId) async {
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery(
      '''
        SELECT work_items.*
        FROM work_items
        INNER JOIN payment_periods
          ON payment_periods.id = work_items.payment_period_id
        INNER JOIN clients ON clients.id = work_items.client_id
        WHERE payment_periods.client_id = ?
          AND payment_periods.status = 'open'
          AND payment_periods.deleted_at IS NULL
          AND work_items.deleted_at IS NULL
          AND clients.deleted_at IS NULL
        ORDER BY work_items.completed_at DESC, work_items.created_at DESC
      ''',
      [clientId],
    );
    return rows.map(WorkItem.fromMap).toList();
  }

  Future<List<WorkItemWithClient>> getFilteredWorkItems(
      WorkItemFilters filters) async {
    final db = await _databaseHelper.database;
    final where = <String>[
      'work_items.deleted_at IS NULL',
      'clients.deleted_at IS NULL',
      'payment_periods.deleted_at IS NULL',
    ];
    final args = <Object?>[];

    if (filters.clientId != null) {
      where.add('work_items.client_id = ?');
      args.add(filters.clientId);
    }
    if (filters.categoryName == WorkItemFilters.customCategoryValue) {
      where.add('work_items.period_category_id IS NULL');
    } else if (filters.categoryName != null) {
      where.add('period_categories.name = ?');
      args.add(filters.categoryName);
    }
    if (filters.startDate != null) {
      where
          .add('COALESCE(work_items.completed_at, work_items.created_at) >= ?');
      args.add(isoDate(_startOfDay(filters.startDate!)));
    }
    if (filters.endDate != null) {
      where.add('COALESCE(work_items.completed_at, work_items.created_at) < ?');
      args.add(
          isoDate(_startOfDay(filters.endDate!).add(const Duration(days: 1))));
    }
    if (filters.minimumAmount != null) {
      where.add('work_items.total_price >= ?');
      args.add(filters.minimumAmount);
    }
    if (filters.maximumAmount != null) {
      where.add('work_items.total_price <= ?');
      args.add(filters.maximumAmount);
    }
    if (filters.minimumQuantity != null) {
      where.add('work_items.quantity >= ?');
      args.add(filters.minimumQuantity);
    }
    if (filters.maximumQuantity != null) {
      where.add('work_items.quantity <= ?');
      args.add(filters.maximumQuantity);
    }
    switch (filters.status) {
      case WorkStatusFilter.all:
        break;
      case WorkStatusFilter.inProgress:
        where.add("work_items.status = 'in_progress'");
        break;
      case WorkStatusFilter.completed:
        where.add("work_items.status = 'completed'");
        break;
    }
    switch (filters.workType) {
      case WorkTypeFilter.all:
        break;
      case WorkTypeFilter.categorized:
        where.add('work_items.period_category_id IS NOT NULL');
        break;
      case WorkTypeFilter.custom:
        where.add('work_items.period_category_id IS NULL');
        break;
    }
    switch (filters.periodStatus) {
      case PeriodStatusFilter.all:
        break;
      case PeriodStatusFilter.open:
        where.add("payment_periods.status = 'open'");
        break;
      case PeriodStatusFilter.closed:
        where.add("payment_periods.status = 'closed'");
        break;
    }

    final rows = await db.rawQuery('''
      SELECT
        work_items.*,
        clients.name AS client_name,
        period_categories.name AS category_name,
        payment_periods.status AS period_status
      FROM work_items
      INNER JOIN clients ON clients.id = work_items.client_id
      INNER JOIN payment_periods ON payment_periods.id = work_items.payment_period_id
      LEFT JOIN period_categories ON period_categories.id = work_items.period_category_id
      WHERE ${where.join(' AND ')}
      ORDER BY work_items.completed_at DESC, work_items.created_at DESC
    ''', args);
    return rows
        .map(
          (row) => WorkItemWithClient(
            workItem: WorkItem.fromMap(row),
            clientName: row['client_name']! as String,
            categoryName: row['category_name'] as String?,
            periodStatus: PaymentPeriodStatus.fromDatabase(
                row['period_status']! as String),
          ),
        )
        .toList();
  }

  Future<List<String>> getWorkItemCategoryNames() async {
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery('''
      SELECT DISTINCT period_categories.name AS category_name
      FROM work_items
      INNER JOIN period_categories ON period_categories.id = work_items.period_category_id
      INNER JOIN payment_periods ON payment_periods.id = work_items.payment_period_id
      INNER JOIN clients ON clients.id = work_items.client_id
      WHERE work_items.deleted_at IS NULL
        AND period_categories.deleted_at IS NULL
        AND payment_periods.deleted_at IS NULL
        AND clients.deleted_at IS NULL
        AND clients.is_active = 1
      ORDER BY period_categories.name COLLATE NOCASE
    ''');
    return rows.map((row) => row['category_name']! as String).toList();
  }

  Future<double> getOpenPeriodTotal(String clientId) async {
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery(
      '''
        SELECT COALESCE(SUM(work_items.total_price), 0) AS total
        FROM work_items
        INNER JOIN payment_periods
          ON payment_periods.id = work_items.payment_period_id
        INNER JOIN clients ON clients.id = work_items.client_id
        WHERE payment_periods.client_id = ?
          AND payment_periods.status = 'open'
          AND payment_periods.deleted_at IS NULL
          AND work_items.deleted_at IS NULL
          AND work_items.status = 'completed'
          AND clients.deleted_at IS NULL
      ''',
      [clientId],
    );
    return (rows.single['total']! as num).toDouble();
  }

  /// Work total of all periods minus recorded payments.
  Future<double> getDashboardTotalUnpaid() async {
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery('''
      SELECT
        COALESCE((
          SELECT SUM(work_items.total_price)
          FROM work_items
          INNER JOIN payment_periods
            ON payment_periods.id = work_items.payment_period_id
          INNER JOIN clients ON clients.id = work_items.client_id
          WHERE work_items.deleted_at IS NULL
            AND work_items.status = 'completed'
            AND payment_periods.deleted_at IS NULL
            AND clients.deleted_at IS NULL
        ), 0) -
        COALESCE((
          SELECT SUM(payments.amount)
          FROM payments
          INNER JOIN payment_periods
            ON payment_periods.id = payments.payment_period_id
          INNER JOIN clients ON clients.id = payments.client_id
          WHERE payments.deleted_at IS NULL
            AND payment_periods.deleted_at IS NULL
            AND clients.deleted_at IS NULL
        ), 0) AS total_unpaid
    ''');
    return (rows.single['total_unpaid']! as num).toDouble();
  }

  Future<List<WorkItem>> getForPeriod(String paymentPeriodId) async {
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery(
      '''
        SELECT work_items.* FROM work_items
        INNER JOIN payment_periods ON payment_periods.id = work_items.payment_period_id
        INNER JOIN clients ON clients.id = work_items.client_id
        WHERE work_items.payment_period_id = ?
          AND work_items.deleted_at IS NULL
          AND payment_periods.deleted_at IS NULL
          AND clients.deleted_at IS NULL
        ORDER BY work_items.completed_at DESC, work_items.created_at DESC
      ''',
      [paymentPeriodId],
    );
    return rows.map(WorkItem.fromMap).toList();
  }

  Future<List<WorkItem>> getWorkItemsForPeriod(String paymentPeriodId) =>
      getForPeriod(paymentPeriodId);

  Future<void> _copyPeriodCategoryStepsToWorkItem(
    DatabaseExecutor executor, {
    required String periodCategoryId,
    required String workItemId,
    required DateTime copiedAt,
  }) async {
    final rows = await executor.query(
      'period_category_steps',
      where: 'period_category_id = ? AND is_active = 1 AND deleted_at IS NULL',
      whereArgs: [periodCategoryId],
      orderBy: 'sort_order ASC, created_at ASC',
    );
    for (final row in rows) {
      final step = WorkItemStep(
        id: _uuid.v4(),
        workItemId: workItemId,
        title: row['title']! as String,
        sortOrder: (row['sort_order']! as num).toInt(),
        createdAt: copiedAt,
        updatedAt: copiedAt,
      );
      await executor.insert(
        'work_item_steps',
        step.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }
  }

  Future<_OpenPeriodCategory> _getOpenPeriodCategory(
    DatabaseExecutor executor,
    String periodCategoryId,
  ) async {
    final rows = await executor.rawQuery(
      '''
        SELECT
          period_categories.id,
          period_categories.client_id,
          period_categories.payment_period_id,
          period_categories.name,
          period_categories.price_snapshot
        FROM period_categories
        INNER JOIN payment_periods
          ON payment_periods.id = period_categories.payment_period_id
        INNER JOIN clients ON clients.id = period_categories.client_id
        WHERE period_categories.id = ?
          AND period_categories.deleted_at IS NULL
          AND payment_periods.status = 'open'
          AND payment_periods.deleted_at IS NULL
          AND clients.is_active = 1
          AND clients.deleted_at IS NULL
        LIMIT 1
      ''',
      [periodCategoryId],
    );
    if (rows.isEmpty) {
      throw StateError('Category not found in the open period.');
    }
    final row = rows.single;
    return _OpenPeriodCategory(
      id: row['id']! as String,
      clientId: row['client_id']! as String,
      paymentPeriodId: row['payment_period_id']! as String,
      name: row['name']! as String,
      priceSnapshot: (row['price_snapshot']! as num).toDouble(),
    );
  }

  Future<_OpenPeriod> _getOpenPeriodForClient(
    DatabaseExecutor executor,
    String clientId,
  ) async {
    final rows = await executor.rawQuery(
      '''
        SELECT payment_periods.id
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
    if (rows.isEmpty) {
      throw StateError('The client has no open period.');
    }
    return _OpenPeriod(rows.single['id']! as String);
  }

  Future<WorkItem> _getOpenWorkItem(
    DatabaseExecutor executor,
    String workItemId,
  ) async {
    final rows = await executor.rawQuery(
      '''
        SELECT work_items.*
        FROM work_items
        INNER JOIN payment_periods
          ON payment_periods.id = work_items.payment_period_id
        INNER JOIN clients ON clients.id = work_items.client_id
        WHERE work_items.id = ?
          AND work_items.deleted_at IS NULL
          AND payment_periods.status = 'open'
          AND payment_periods.deleted_at IS NULL
          AND clients.is_active = 1
          AND clients.deleted_at IS NULL
        LIMIT 1
      ''',
      [workItemId],
    );
    if (rows.isEmpty) {
      throw StateError('Only work in the open period can be changed.');
    }
    return WorkItem.fromMap(rows.single);
  }
}

DateTime _startOfDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);

class _OpenPeriodCategory {
  const _OpenPeriodCategory({
    required this.id,
    required this.clientId,
    required this.paymentPeriodId,
    required this.name,
    required this.priceSnapshot,
  });

  final String id;
  final String clientId;
  final String paymentPeriodId;
  final String name;
  final double priceSnapshot;
}

class _OpenPeriod {
  const _OpenPeriod(this.id);

  final String id;
}
