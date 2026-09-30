import 'package:flowledger/models/client.dart';
import 'package:flowledger/models/payment_period.dart';
import 'package:flowledger/repositories/payment_period_repository.dart';
import 'package:flowledger/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class ClientRepository {
  ClientRepository({DatabaseHelper? databaseHelper, Uuid? uuid})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance,
        _uuid = uuid ?? const Uuid();

  final DatabaseHelper _databaseHelper;
  final Uuid _uuid;

  /// Creates the client and its first open period in one transaction.
  Future<Client> createClient(String name, [String? notes]) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Client name cannot be empty.');
    }

    final now = DateTime.now();
    final client = Client(
      id: _uuid.v4(),
      name: normalizedName,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
    await insert(client);
    return client;
  }

  /// Alias of [createClient].
  Future<Client> create({required String name, String? notes}) =>
      createClient(name, notes);

  Future<void> insert(Client client) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now();
    await db.transaction((transaction) async {
      await transaction.insert(
        'clients',
        client.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      await _insertOpenPeriod(transaction, client.id, now);
    });
  }

  Future<List<Client>> getClients() async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'clients',
      where: 'is_active = 1 AND deleted_at IS NULL',
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(Client.fromMap).toList();
  }

  Future<void> softDeleteClient(String clientId) async {
    final db = await _databaseHelper.database;
    final now = DateTime.now().toUtc().toIso8601String();
    final affected = await db.update(
      'clients',
      {'is_active': 0, 'updated_at': now, 'deleted_at': now},
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [clientId],
    );
    if (affected != 1) {
      throw StateError('Client not found or already deleted.');
    }
  }

  Future<PaymentPeriod?> getOpenPeriodForClient(String clientId) async {
    final db = await _databaseHelper.database;
    final rows = await db.query(
      'payment_periods',
      where: "client_id = ? AND status = 'open' AND deleted_at IS NULL",
      whereArgs: [clientId],
      limit: 1,
    );
    return rows.isEmpty ? null : PaymentPeriod.fromMap(rows.single);
  }

  /// Returns the open period, creating it if missing. A partial unique index
  /// prevents a second open period.
  Future<PaymentPeriod> ensureOpenPeriodForClient(String clientId) async {
    return PaymentPeriodRepository(
      databaseHelper: _databaseHelper,
      uuid: _uuid,
    ).ensureOpenPeriodForClient(clientId);
  }

  Future<PaymentPeriod> _insertOpenPeriod(
    Transaction transaction,
    String clientId,
    DateTime now,
  ) async {
    final period = PaymentPeriod(
      id: _uuid.v4(),
      clientId: clientId,
      startDate: now,
      createdAt: now,
      updatedAt: now,
    );
    await transaction.insert(
      'payment_periods',
      period.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return period;
  }
}
