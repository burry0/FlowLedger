import 'dart:io';

import 'package:flowledger/repositories/client_repository.dart';
import 'package:flowledger/repositories/work_item_repository.dart';
import 'package:flowledger/services/database_helper.dart';
import 'package:flowledger/widgets/backup_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/ledger_fixture.dart';
import 'support/test_database.dart';
import 'support/widget_harness.dart';

void main() {
  late TestDatabase testDatabase;
  late DatabaseHelper helper;
  late LedgerFixture fixture;

  setUp(() async {
    testDatabase = await TestDatabase.create();
    helper = testDatabase.helper();
    fixture = await LedgerFixture.seed(helper);
  });
  tearDown(() async => testDatabase.dispose());

  String fileIn(String name) => path.join(testDatabase.directory.path, name);

  Future<List<String>> clientNames(DatabaseHelper h) async =>
      (await ClientRepository(databaseHelper: h).getClients())
          .map((c) => c.name)
          .toList();

  test('creates a backup and validates it', () async {
    final backup = fileIn('yedek.db');
    await helper.backupTo(backup);
    await helper.backupTo(backup); // üzerine yazma da çalışır

    final info = await helper.inspectBackup(backup);
    expect(info.schemaVersion, DatabaseHelper.databaseVersion);
    expect(info.clientCount, 1);
    expect(info.workItemCount, 3);
  });

  test('restore replaces the data after taking a safety copy', () async {
    final backup = fileIn('yedek.db');
    await helper.backupTo(backup);

    await ClientRepository(databaseHelper: helper)
        .createClient('Yedekten sonra eklenen');
    expect(await clientNames(helper), hasLength(2));

    final safety = await helper.restoreFrom(backup);

    expect(await clientNames(helper), ['Örnek Stüdyo']);
    expect(
      (await WorkItemRepository(databaseHelper: helper)
          .getOpenPeriodTotal(fixture.clientId)),
      1500,
    );
    expect(File(safety).existsSync(), isTrue);
    expect(path.basename(safety), contains('pre-restore'));
    final safetyInfo = await helper.inspectBackup(safety);
    expect(safetyInfo.clientCount, 2);
    expect(
        File('${testDatabase.databasePath}.restore-tmp').existsSync(), isFalse);
  });

  test('an older backup is upgraded on restore', () async {
    final old = await TestDatabase.create();
    try {
      final v3 = old.helper(targetVersion: 3);
      await ClientRepository(databaseHelper: v3).createClient('Eski müşteri');
      final oldBackup = fileIn('eski.db');
      await v3.backupTo(oldBackup);
      await v3.close();

      expect((await helper.inspectBackup(oldBackup)).schemaVersion, 3);
      await helper.restoreFrom(oldBackup);

      final db = await helper.database;
      expect(await db.getVersion(), DatabaseHelper.databaseVersion);
      expect(await clientNames(helper), ['Eski müşteri']);
      final tables = (await db
              .rawQuery("SELECT name FROM sqlite_master WHERE type = 'table'"))
          .map((row) => row['name']);
      expect(tables, contains('work_item_versions'));
    } finally {
      await old.dispose();
    }
  });

  test('invalid files are rejected and live data is unchanged', () async {
    final text = fileIn('not.txt');
    File(text).writeAsStringSync('merhaba');
    final newer = fileIn('newer.db');
    final foreign = fileIn('foreign.db');

    sqfliteFfiInit();
    final n = await databaseFactoryFfi.openDatabase(newer,
        options: OpenDatabaseOptions(
            version: 99,
            onCreate: (db, _) => db.execute('CREATE TABLE clients (id TEXT)')));
    await n.close();
    final f = await databaseFactoryFfi.openDatabase(foreign,
        options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, _) => db.execute('CREATE TABLE notes (id TEXT)')));
    await f.close();

    Future<void> expectProblem(String file, BackupProblem problem) =>
        expectLater(
          helper.restoreFrom(file),
          throwsA(isA<BackupValidationException>()
              .having((e) => e.problem, 'problem', problem)),
        );

    await expectProblem(fileIn('yok.db'), BackupProblem.notFound);
    await expectProblem(text, BackupProblem.notABackup);
    await expectProblem(newer, BackupProblem.newerVersion);
    await expectProblem(foreign, BackupProblem.notABackup);

    expect(await clientNames(helper), ['Örnek Stüdyo']);
    final leftovers = testDatabase.directory
        .listSync()
        .map((e) => path.basename(e.path))
        .where((n) => n.contains('pre-restore') || n.contains('restore-tmp'));
    expect(leftovers, isEmpty);
  });

  testWidgets('settings backup section in two languages', (tester) async {
    for (final (locale, create, restore) in const [
      (Locale('tr'), 'Yedek al', 'Yedekten geri yükle'),
      (Locale('en'), 'Create backup', 'Restore from backup'),
    ]) {
      await tester.pumpWidget(localizedApp(
        Scaffold(body: BackupSection(databaseHelper: helper)),
        locale: locale,
      ));
      await tester.pumpAndSettle();
      expect(find.text(create), findsOneWidget);
      expect(find.text(restore), findsOneWidget);
    }
  });
}
