import 'package:flowledger/services/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/test_database.dart';

Future<Set<String>> _tableNames(Database db) async {
  final rows = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type = 'table'",
  );
  return rows.map((row) => row['name']! as String).toSet();
}

void main() {
  late TestDatabase testDatabase;

  setUp(() async => testDatabase = await TestDatabase.create());
  tearDown(() async => testDatabase.dispose());

  test('fresh install creates the current schema', () async {
    final helper = testDatabase.helper();
    final db = await helper.database;

    expect(await db.getVersion(), DatabaseHelper.databaseVersion);
    expect(
      await _tableNames(db),
      containsAll(<String>[
        'clients',
        'payment_periods',
        'work_items',
        'work_item_steps',
        'payments',
        'app_settings',
      ]),
    );
    expect(helper.lastBackupPath, isNull);
    expect(testDatabase.backupFiles(), isEmpty);
  });

  test('concurrent first access opens one connection', () async {
    final helper = testDatabase.helper();
    final results = await Future.wait([helper.database, helper.database]);
    expect(identical(results[0], results[1]), isTrue);
  });

  test('no backup for a database already on the current version', () async {
    await testDatabase.helper().database;
    await testDatabase.dispose();
    testDatabase = await TestDatabase.create();

    final first = testDatabase.helper();
    await first.database;
    await first.close();

    final second = testDatabase.helper();
    await second.database;
    expect(second.lastBackupPath, isNull);
    expect(testDatabase.backupFiles(), isEmpty);
  });

  test('an older database is backed up with its WAL content before upgrading',
      () async {
    // v2 database; the connection stays open so data remains in the WAL file.
    final oldHelper = testDatabase.helper(targetVersion: 2);
    final oldDb = await oldHelper.database;
    await oldDb.insert('app_settings', {'key': 'theme_mode', 'value': 'light'});

    final newHelper = testDatabase.helper(
      targetVersion: 3,
      clock: () => DateTime.utc(2026, 9, 30, 12, 0, 0),
    );
    final newDb = await newHelper.database;
    await oldHelper.close();

    expect(await newDb.getVersion(), 3);
    expect(await _tableNames(newDb), contains('work_item_steps'));
    final migrated = await newDb.query('app_settings');
    expect(migrated.single['value'], 'light');

    final backupPath = newHelper.lastBackupPath;
    expect(backupPath, isNotNull);
    expect(backupPath, endsWith('flowledger.v2-backup-20260930-120000.db'));
    expect(testDatabase.backupFiles(), hasLength(1));

    final backup = await databaseFactoryFfi.openDatabase(
      backupPath!,
      options: OpenDatabaseOptions(readOnly: true),
    );
    try {
      expect(await backup.getVersion(), 2);
      expect(await _tableNames(backup), isNot(contains('work_item_steps')));
      final settings = await backup.query('app_settings');
      expect(settings.single['value'], 'light');
    } finally {
      await backup.close();
    }
  });

  test('a second backup in the same second does not overwrite the first',
      () async {
    DateTime clock() => DateTime.utc(2026, 9, 30, 12, 0, 0);
    final v1 = testDatabase.helper(targetVersion: 1);
    await v1.database;
    await v1.close();
    final v2 = testDatabase.helper(targetVersion: 2, clock: clock);
    await v2.database;
    await v2.close();
    final v3 = testDatabase.helper(targetVersion: 3, clock: clock);
    await v3.database;

    final names = testDatabase.backupFiles().map((f) => f.path).toList();
    expect(names, hasLength(2));
    expect(names.any((n) => n.contains('.v1-backup-')), isTrue);
    expect(names.any((n) => n.contains('.v2-backup-')), isTrue);
  });
}
