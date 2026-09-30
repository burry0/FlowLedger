import 'dart:io';

import 'package:flowledger/repositories/client_repository.dart';
import 'package:flowledger/services/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory root;
  late String legacyPath;
  late String newPath;

  setUp(() {
    sqfliteFfiInit();
    root = Directory.systemTemp.createTempSync('flowledger_legacy_');
    legacyPath =
        path.join(root.path, 'com.example', 'FlowLedger', 'burry_ledger.db');
    newPath = path.join(
        root.path, 'com.burry.flowledger', 'FlowLedger', 'flowledger.db');
  });
  tearDown(() => root.deleteSync(recursive: true));

  Future<void> seedLegacy({bool keepOpen = false}) async {
    Directory(path.dirname(legacyPath)).createSync(recursive: true);
    final legacy = DatabaseHelper.forTesting(
      databaseFactory: databaseFactoryFfi,
      databasePath: legacyPath,
    );
    await ClientRepository(databaseHelper: legacy).createClient('Eski veri');
    if (!keepOpen) await legacy.close();
  }

  test('legacy data is copied and the original kept', () async {
    await seedLegacy();
    final moved = await DatabaseHelper.migrateLegacyDatabase(
      databaseFactoryFfi,
      legacyPath: legacyPath,
      newPath: newPath,
    );
    expect(moved, isTrue);
    expect(File(legacyPath).existsSync(), isTrue);
    expect(File('$newPath.migrating').existsSync(), isFalse);

    final helper = DatabaseHelper.forTesting(
      databaseFactory: databaseFactoryFfi,
      databasePath: newPath,
    );
    final names = (await ClientRepository(databaseHelper: helper).getClients())
        .map((c) => c.name);
    expect(names, ['Eski veri']);
    await helper.close();
  });

  test('existing data in the new location is left alone', () async {
    await seedLegacy();
    Directory(path.dirname(newPath)).createSync(recursive: true);
    File(newPath).writeAsStringSync('mevcut');
    final moved = await DatabaseHelper.migrateLegacyDatabase(
      databaseFactoryFfi,
      legacyPath: legacyPath,
      newPath: newPath,
    );
    expect(moved, isFalse);
    expect(File(newPath).readAsStringSync(), 'mevcut');
  });

  test('fresh install copies nothing', () async {
    final moved = await DatabaseHelper.migrateLegacyDatabase(
      databaseFactoryFfi,
      legacyPath: legacyPath,
      newPath: newPath,
    );
    expect(moved, isFalse);
    expect(File(newPath).existsSync(), isFalse);
  });

  test('a database with the old file name in the same folder is copied',
      () async {
    final dir = path.join(root.path, 'com.burry.flowledger', 'FlowLedger');
    final oldName = path.join(dir, 'burry_ledger.db');
    final newName = path.join(dir, 'flowledger.db');
    Directory(dir).createSync(recursive: true);
    final old = DatabaseHelper.forTesting(
      databaseFactory: databaseFactoryFfi,
      databasePath: oldName,
    );
    await ClientRepository(databaseHelper: old).createClient('Same folder');
    await old.close();

    expect(
      await DatabaseHelper.migrateLegacyDatabase(databaseFactoryFfi,
          legacyPath: oldName, newPath: newName),
      isTrue,
    );
    final helper = DatabaseHelper.forTesting(
      databaseFactory: databaseFactoryFfi,
      databasePath: newName,
    );
    expect(
      (await ClientRepository(databaseHelper: helper).getClients())
          .map((c) => c.name),
      ['Same folder'],
    );
    await helper.close();
    expect(File(oldName).existsSync(), isTrue);
  });
}
