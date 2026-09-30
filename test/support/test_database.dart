import 'dart:io';

import 'package:flowledger/services/database_helper.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// A file-based SQLite database in a temp folder, away from real app data.
class TestDatabase {
  TestDatabase._(this.directory);

  final Directory directory;
  final List<DatabaseHelper> _helpers = [];

  static Future<TestDatabase> create() async {
    sqfliteFfiInit();
    final directory = await Directory.systemTemp.createTemp('flowledger_test_');
    return TestDatabase._(directory);
  }

  String get databasePath => path.join(directory.path, 'flowledger.db');

  DatabaseHelper helper({int? targetVersion, DateTime Function()? clock}) {
    final helper = DatabaseHelper.forTesting(
      databaseFactory: databaseFactoryFfi,
      databasePath: databasePath,
      targetVersion: targetVersion,
      clock: clock,
    );
    _helpers.add(helper);
    return helper;
  }

  List<File> backupFiles() => directory
      .listSync()
      .whereType<File>()
      .where((file) => path.basename(file.path).contains('-backup-'))
      .toList();

  Future<void> dispose() async {
    for (final helper in _helpers) {
      await helper.close();
    }
    if (directory.existsSync()) {
      await directory.delete(recursive: true);
    }
  }
}
