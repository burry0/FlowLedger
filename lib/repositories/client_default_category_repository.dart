import 'package:flowledger/models/category_step_template.dart';
import 'package:flowledger/models/client_default_category.dart';
import 'package:flowledger/models/model_converters.dart';
import 'package:flowledger/repositories/payment_period_repository.dart';
import 'package:flowledger/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class ClientDefaultCategoryRepository {
  ClientDefaultCategoryRepository({DatabaseHelper? databaseHelper, Uuid? uuid})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance,
        _uuid = uuid ?? const Uuid();

  final DatabaseHelper _databaseHelper;
  final Uuid _uuid;

  Future<ClientDefaultCategory> createDefaultCategory(
    String clientId,
    String name,
    double price, {
    List<String> stepTitles = const [],
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Category name cannot be empty.');
    }
    if (price < 0) {
      throw ArgumentError.value(
          price, 'price', 'Category price cannot be negative.');
    }

    final now = DateTime.now();
    final category = ClientDefaultCategory(
      id: _uuid.v4(),
      clientId: clientId,
      name: normalizedName,
      price: price,
      createdAt: now,
      updatedAt: now,
    );
    final db = await _databaseHelper.database;
    await db.transaction((transaction) async {
      await transaction.insert(
        'client_default_categories',
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      await _replaceSteps(
        transaction,
        clientId: clientId,
        categoryId: category.id,
        stepTitles: stepTitles,
        updatedAt: now,
      );
    });
    await PaymentPeriodRepository(databaseHelper: _databaseHelper, uuid: _uuid)
        .addDefaultCategorySnapshotToOpenPeriod(category);
    return category;
  }

  Future<ClientDefaultCategory> create({
    required String clientId,
    required String name,
    required double price,
  }) =>
      createDefaultCategory(clientId, name, price);

  Future<void> insert(ClientDefaultCategory category) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'client_default_categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> updateDefaultCategory(
    String categoryId,
    String name,
    double price, {
    List<String>? stepTitles,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Category name cannot be empty.');
    }
    if (price < 0) {
      throw ArgumentError.value(
          price, 'price', 'Category price cannot be negative.');
    }

    final db = await _databaseHelper.database;
    await db.transaction((transaction) async {
      final rows = await transaction.query(
        'client_default_categories',
        columns: ['client_id'],
        where: 'id = ? AND deleted_at IS NULL',
        whereArgs: [categoryId],
        limit: 1,
      );
      if (rows.isEmpty) {
        throw StateError('Default category not found.');
      }
      final now = DateTime.now();
      final updated = await transaction.update(
        'client_default_categories',
        {
          'name': normalizedName,
          'price': price,
          'updated_at': isoDate(now),
        },
        where: 'id = ? AND deleted_at IS NULL',
        whereArgs: [categoryId],
      );
      if (updated != 1) {
        throw StateError('Default category not found.');
      }
      if (stepTitles != null) {
        await _replaceSteps(
          transaction,
          clientId: rows.single['client_id']! as String,
          categoryId: categoryId,
          stepTitles: stepTitles,
          updatedAt: now,
        );
      }
    });
  }

  Future<void> softDeleteDefaultCategory(String categoryId) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final db = await _databaseHelper.database;
    final updated = await db.update(
      'client_default_categories',
      {
        'is_active': 0,
        'updated_at': now,
        'deleted_at': now,
      },
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [categoryId],
    );
    if (updated != 1) {
      throw StateError('Default category not found.');
    }
  }

  Future<List<ClientDefaultCategory>> getDefaultCategoriesForClient(
      String clientId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'client_default_categories',
      where: 'client_id = ? AND is_active = 1 AND deleted_at IS NULL',
      whereArgs: [clientId],
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(ClientDefaultCategory.fromMap).toList();
  }

  Future<List<ClientDefaultCategoryStep>> getStepsForCategory(
      String categoryId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'client_default_category_steps',
      where: 'default_category_id = ? AND is_active = 1 AND deleted_at IS NULL',
      whereArgs: [categoryId],
      orderBy: 'sort_order ASC, created_at ASC',
    );
    return rows.map(ClientDefaultCategoryStep.fromMap).toList();
  }

  Future<void> _replaceSteps(
    DatabaseExecutor executor, {
    required String clientId,
    required String categoryId,
    required List<String> stepTitles,
    required DateTime updatedAt,
  }) async {
    final now = isoDate(updatedAt);
    await executor.update(
      'client_default_category_steps',
      {
        'is_active': 0,
        'updated_at': now,
        'deleted_at': now,
      },
      where: 'default_category_id = ? AND deleted_at IS NULL',
      whereArgs: [categoryId],
    );

    for (var index = 0; index < stepTitles.length; index++) {
      final title = stepTitles[index].trim();
      if (title.isEmpty) {
        continue;
      }
      final step = ClientDefaultCategoryStep(
        id: _uuid.v4(),
        clientId: clientId,
        defaultCategoryId: categoryId,
        title: title,
        sortOrder: index,
        createdAt: updatedAt,
        updatedAt: updatedAt,
      );
      await executor.insert(
        'client_default_category_steps',
        step.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }
  }
}
