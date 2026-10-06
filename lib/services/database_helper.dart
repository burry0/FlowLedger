import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Opens the local SQLite database and runs schema migrations.
class DatabaseHelper {
  DatabaseHelper._({
    DatabaseFactory? databaseFactoryOverride,
    String? databasePathOverride,
    int? targetVersion,
    DateTime Function()? clock,
  })  : _databaseFactoryOverride = databaseFactoryOverride,
        _databasePathOverride = databasePathOverride,
        _targetVersion = targetVersion ?? databaseVersion,
        _clock = clock ?? DateTime.now;

  /// Opens a database outside the app data folder, for tests.
  /// [targetVersion] creates an older schema so migrations can be tested.
  @visibleForTesting
  DatabaseHelper.forTesting({
    required DatabaseFactory databaseFactory,
    required String databasePath,
    int? targetVersion,
    DateTime Function()? clock,
  }) : this._(
          databaseFactoryOverride: databaseFactory,
          databasePathOverride: databasePath,
          targetVersion: targetVersion,
          clock: clock,
        );

  static DatabaseHelper _instance = DatabaseHelper._();

  static DatabaseHelper get instance => _instance;

  /// Lets widget tests point the default repositories at a temp database.
  @visibleForTesting
  static void overrideInstanceForTesting(DatabaseHelper helper) {
    _instance = helper;
  }

  static const databaseVersion = 7;
  static const _databaseFileName = 'flowledger.db';

  /// File name used before 1.0.
  static const _legacyDatabaseFileName = 'burry_ledger.db';

  final DatabaseFactory? _databaseFactoryOverride;
  final String? _databasePathOverride;
  final int _targetVersion;
  final DateTime Function() _clock;

  Database? _database;
  Future<Database>? _opening;
  String? _openedPath;

  /// Path of the copy taken before the last schema upgrade, if any.
  String? lastBackupPath;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }
    return _opening ??= _openDatabase().then((db) {
      _database = db;
      return db;
    }).whenComplete(() => _opening = null);
  }

  Future<void> initialize() async {
    await database;
  }

  /// Closes the connection. Used by tests.
  @visibleForTesting
  Future<void> close() async {
    final db = _database;
    _database = null;
    await db?.close();
  }

  Future<Database> _openDatabase() async {
    final factory = _resolveDatabaseFactory();
    final databasePath = await _resolveDatabasePath();

    await _backupBeforeUpgrade(factory, databasePath);

    _openedPath = databasePath;
    return factory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: _targetVersion,
        onConfigure: _configure,
        onCreate: (db, version) => _runMigrations(db, 0, version),
        onUpgrade: (db, oldVersion, newVersion) =>
            _runMigrations(db, oldVersion, newVersion),
      ),
    );
  }

  DatabaseFactory _resolveDatabaseFactory() {
    final override = _databaseFactoryOverride;
    if (override != null) {
      return override;
    }
    if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    return databaseFactory;
  }

  Future<String> _resolveDatabasePath() async {
    final override = _databasePathOverride;
    if (override != null) {
      return override;
    }
    final directory = await getApplicationSupportDirectory();
    final databasePath = path.join(directory.path, _databaseFileName);
    final legacyPaths = [
      path.join(directory.path, _legacyDatabaseFileName),
      if (Platform.isWindows)
        // Builds before 1.0 used the "com.example" company name, so their data
        // lives in %APPDATA%\com.example\FlowLedger.
        path.join(
          path.dirname(path.dirname(directory.path)),
          _legacyCompanyName,
          'FlowLedger',
          _legacyDatabaseFileName,
        ),
    ];
    for (final legacyPath in legacyPaths) {
      final copied = await migrateLegacyDatabase(
        _resolveDatabaseFactory(),
        legacyPath: legacyPath,
        newPath: databasePath,
      );
      if (copied) break;
    }
    return databasePath;
  }

  static const _legacyCompanyName = 'com.example';

  /// Copies the database at [legacyPath] (including WAL content) to [newPath]
  /// when only the legacy one exists. The legacy files are kept. Returns true
  /// if a copy was made.
  @visibleForTesting
  static Future<bool> migrateLegacyDatabase(
    DatabaseFactory factory, {
    required String legacyPath,
    required String newPath,
  }) async {
    if (legacyPath == newPath ||
        File(newPath).existsSync() ||
        !File(legacyPath).existsSync()) {
      return false;
    }
    Directory(path.dirname(newPath)).createSync(recursive: true);
    final staged = '$newPath.migrating';
    final stagedFile = File(staged);
    if (stagedFile.existsSync()) {
      stagedFile.deleteSync();
    }
    final legacy = await factory.openDatabase(
      legacyPath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    try {
      await legacy.execute('VACUUM INTO ?', [staged]);
    } finally {
      await legacy.close();
    }
    // Never let a partial copy take the live file name.
    stagedFile.renameSync(newPath);
    return true;
  }

  static Future<void> _configure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('PRAGMA journal_mode = WAL');
  }

  /// Writes a copy next to the database before migrating an older schema.
  /// `VACUUM INTO` is used instead of a file copy because in WAL mode the main
  /// file may not contain the latest changes. If the copy fails, the migration
  /// does not run.
  Future<void> _backupBeforeUpgrade(
    DatabaseFactory factory,
    String databasePath,
  ) async {
    lastBackupPath = null;
    if (databasePath == inMemoryDatabasePath ||
        !await factory.databaseExists(databasePath)) {
      return;
    }

    final db = await factory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(onConfigure: _configure),
    );
    try {
      final currentVersion = await db.getVersion();
      if (currentVersion <= 0 || currentVersion >= _targetVersion) {
        return;
      }
      final backupPath = _backupPathFor(databasePath, currentVersion);
      await db.execute('VACUUM INTO ?', [backupPath]);
      lastBackupPath = backupPath;
    } on Object catch (error) {
      throw StateError(
        'Could not back up the database before upgrading; '
        'the migration was not started. Cause: $error',
      );
    } finally {
      await db.close();
    }
  }

  String _backupPathFor(String databasePath, int fromVersion) {
    final now = _clock().toUtc();
    String two(int value) => value.toString().padLeft(2, '0');
    final stamp = '${now.year}${two(now.month)}${two(now.day)}-'
        '${two(now.hour)}${two(now.minute)}${two(now.second)}';
    final base = path.basenameWithoutExtension(databasePath);
    var candidate = path.join(
      path.dirname(databasePath),
      '$base.v$fromVersion-backup-$stamp.db',
    );
    var suffix = 1;
    while (File(candidate).existsSync()) {
      candidate = path.join(
        path.dirname(databasePath),
        '$base.v$fromVersion-backup-$stamp-$suffix.db',
      );
      suffix++;
    }
    return candidate;
  }

  /// Writes a consistent copy of the database to [targetPath], replacing any
  /// existing file.
  Future<void> backupTo(String targetPath) async {
    final db = await database;
    final target = File(targetPath);
    if (target.existsSync()) {
      target.deleteSync();
    }
    await db.execute('VACUUM INTO ?', [targetPath]);
  }

  /// Checks that [path] is a FlowLedger backup that can be restored. Read-only.
  Future<BackupInfo> inspectBackup(String path) async {
    if (!File(path).existsSync()) {
      throw const BackupValidationException(BackupProblem.notFound);
    }
    final factory = _resolveDatabaseFactory();
    Database? db;
    try {
      db = await factory.openDatabase(
        path,
        options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
      );
      final version = await db.getVersion();
      if (version <= 0) {
        throw const BackupValidationException(BackupProblem.notABackup);
      }
      if (version > databaseVersion) {
        throw const BackupValidationException(BackupProblem.newerVersion);
      }
      final tables = (await db
              .rawQuery("SELECT name FROM sqlite_master WHERE type = 'table'"))
          .map((row) => row['name'])
          .toSet();
      const required = {
        'clients',
        'payment_periods',
        'work_items',
        'payments',
      };
      if (!tables.containsAll(required)) {
        throw const BackupValidationException(BackupProblem.notABackup);
      }
      final integrity = await db.rawQuery('PRAGMA integrity_check');
      if (integrity.isEmpty || integrity.first.values.first != 'ok') {
        throw const BackupValidationException(BackupProblem.corrupted);
      }
      Future<int> count(String table) async => ((await db!.rawQuery(
                  'SELECT COUNT(*) AS c FROM $table WHERE deleted_at IS NULL'))
              .single['c']! as num)
          .toInt();
      return BackupInfo(
        schemaVersion: version,
        clientCount: await count('clients'),
        workItemCount: await count('work_items'),
      );
    } on BackupValidationException {
      rethrow;
    } on Object {
      throw const BackupValidationException(BackupProblem.notABackup);
    } finally {
      await db?.close();
    }
  }

  /// Replaces the current data with [backupPath] and returns the path of the
  /// safety copy taken first. If the restored database cannot be opened, the
  /// safety copy is put back and the error is rethrown. Older backups are
  /// upgraded by the normal migrations.
  Future<String> restoreFrom(String backupPath) async {
    await inspectBackup(backupPath);
    await database;
    final livePath = _openedPath;
    if (livePath == null || livePath == inMemoryDatabasePath) {
      throw StateError('Cannot restore into an in-memory database.');
    }
    final directory = path.dirname(livePath);
    final base = path.basenameWithoutExtension(livePath);
    final safetyPath = _uniquePath(
      directory,
      '$base.pre-restore-${_stamp()}',
    );
    await backupTo(safetyPath);

    // Stage the backup in the same folder so a partial copy never replaces the live file.
    final staged = '$livePath.restore-tmp';
    File(backupPath).copySync(staged);

    await close();
    _replaceDatabaseFile(livePath, staged);
    try {
      await database;
    } on Object {
      await close();
      _replaceDatabaseFile(livePath, safetyPath, keepSource: true);
      await database;
      rethrow;
    }
    return safetyPath;
  }

  static void _replaceDatabaseFile(
    String livePath,
    String sourcePath, {
    bool keepSource = false,
  }) {
    for (final suffix in ['', '-wal', '-shm', '-journal']) {
      final file = File('$livePath$suffix');
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
    if (keepSource) {
      File(sourcePath).copySync(livePath);
    } else {
      File(sourcePath).renameSync(livePath);
    }
  }

  String _stamp() {
    final now = _clock().toUtc();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}-'
        '${two(now.hour)}${two(now.minute)}${two(now.second)}';
  }

  static String _uniquePath(String directory, String stem) {
    var candidate = path.join(directory, '$stem.db');
    var suffix = 1;
    while (File(candidate).existsSync()) {
      candidate = path.join(directory, '$stem-$suffix.db');
      suffix++;
    }
    return candidate;
  }

  Future<void> _runMigrations(
    DatabaseExecutor executor,
    int fromVersion,
    int toVersion,
  ) async {
    for (var version = fromVersion + 1; version <= toVersion; version++) {
      final migration = _migrations[version];
      if (migration == null) {
        throw StateError('Database migration $version is not defined.');
      }
      await migration(executor);
    }
  }

  static final Map<int, Future<void> Function(DatabaseExecutor)> _migrations = {
    1: _createVersion1,
    2: _createVersion2,
    3: _createVersion3,
    4: _createVersion4,
    5: _createVersion5,
    6: _createVersion6,
    7: _createVersion7,
  };

  static Future<void> _createVersion1(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE clients (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        notes TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE client_default_categories (
        id TEXT PRIMARY KEY,
        client_id TEXT NOT NULL,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        FOREIGN KEY (client_id) REFERENCES clients(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE payment_periods (
        id TEXT PRIMARY KEY,
        client_id TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        status TEXT NOT NULL DEFAULT 'open',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        FOREIGN KEY (client_id) REFERENCES clients(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE period_categories (
        id TEXT PRIMARY KEY,
        client_id TEXT NOT NULL,
        payment_period_id TEXT NOT NULL,
        source_default_category_id TEXT,
        name TEXT NOT NULL,
        price_snapshot REAL NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        FOREIGN KEY (client_id) REFERENCES clients(id),
        FOREIGN KEY (payment_period_id) REFERENCES payment_periods(id),
        FOREIGN KEY (source_default_category_id)
          REFERENCES client_default_categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE work_items (
        id TEXT PRIMARY KEY,
        client_id TEXT NOT NULL,
        payment_period_id TEXT NOT NULL,
        period_category_id TEXT,
        title TEXT NOT NULL,
        price_snapshot REAL NOT NULL,
        quantity REAL NOT NULL DEFAULT 1,
        total_price REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'completed',
        completed_at TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        FOREIGN KEY (client_id) REFERENCES clients(id),
        FOREIGN KEY (payment_period_id) REFERENCES payment_periods(id),
        FOREIGN KEY (period_category_id) REFERENCES period_categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        client_id TEXT NOT NULL,
        payment_period_id TEXT NOT NULL,
        amount REAL NOT NULL,
        paid_at TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        FOREIGN KEY (client_id) REFERENCES clients(id),
        FOREIGN KEY (payment_period_id) REFERENCES payment_periods(id)
      )
    ''');

    await db.execute('''
      CREATE UNIQUE INDEX payment_periods_one_open_per_client
      ON payment_periods (client_id)
      WHERE status = 'open' AND deleted_at IS NULL
    ''');
    await db.execute('''
      CREATE INDEX client_default_categories_by_client
      ON client_default_categories (client_id, is_active)
      WHERE deleted_at IS NULL
    ''');
    await db.execute('''
      CREATE INDEX period_categories_by_period
      ON period_categories (payment_period_id, is_active)
      WHERE deleted_at IS NULL
    ''');
    await db.execute('''
      CREATE INDEX work_items_by_period
      ON work_items (payment_period_id)
      WHERE deleted_at IS NULL
    ''');
    await db.execute('''
      CREATE INDEX payments_by_period
      ON payments (payment_period_id)
      WHERE deleted_at IS NULL
    ''');
  }

  static Future<void> _createVersion2(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _createVersion3(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE client_default_category_steps (
        id TEXT PRIMARY KEY,
        client_id TEXT NOT NULL,
        default_category_id TEXT NOT NULL,
        title TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        FOREIGN KEY (client_id) REFERENCES clients(id),
        FOREIGN KEY (default_category_id)
          REFERENCES client_default_categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE period_category_steps (
        id TEXT PRIMARY KEY,
        client_id TEXT NOT NULL,
        payment_period_id TEXT NOT NULL,
        period_category_id TEXT NOT NULL,
        source_default_step_id TEXT,
        title TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        FOREIGN KEY (client_id) REFERENCES clients(id),
        FOREIGN KEY (payment_period_id) REFERENCES payment_periods(id),
        FOREIGN KEY (period_category_id) REFERENCES period_categories(id),
        FOREIGN KEY (source_default_step_id)
          REFERENCES client_default_category_steps(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE work_item_steps (
        id TEXT PRIMARY KEY,
        work_item_id TEXT NOT NULL,
        title TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        is_done INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        FOREIGN KEY (work_item_id) REFERENCES work_items(id)
      )
    ''');

    await db.execute('''
      CREATE INDEX client_default_category_steps_by_category
      ON client_default_category_steps (default_category_id, sort_order)
      WHERE deleted_at IS NULL
    ''');
    await db.execute('''
      CREATE INDEX period_category_steps_by_category
      ON period_category_steps (period_category_id, sort_order)
      WHERE deleted_at IS NULL
    ''');
    await db.execute('''
      CREATE INDEX work_item_steps_by_work_item
      ON work_item_steps (work_item_id, sort_order)
      WHERE deleted_at IS NULL
    ''');
    await db.execute('''
      CREATE INDEX work_items_by_period_status
      ON work_items (payment_period_id, status)
      WHERE deleted_at IS NULL
    ''');
  }

  /// Revision tracking: versions and feedback per work item. Adds tables only.
  /// `IF NOT EXISTS` because an older build lowers the version number to 3 but
  /// leaves the tables in place; upgrading again must keep that data.
  static Future<void> _createVersion4(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS work_item_versions (
        id TEXT PRIMARY KEY,
        work_item_id TEXT NOT NULL,
        sequence_no INTEGER NOT NULL,
        label TEXT NOT NULL,
        notes TEXT,
        link TEXT,
        status TEXT NOT NULL DEFAULT 'draft'
          CHECK (status IN ('draft', 'sent', 'approved')),
        sent_at TEXT,
        approved_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        FOREIGN KEY (work_item_id) REFERENCES work_items(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS work_item_feedback (
        id TEXT PRIMARY KEY,
        work_item_id TEXT NOT NULL,
        version_id TEXT,
        body TEXT NOT NULL,
        kind TEXT NOT NULL DEFAULT 'revision'
          CHECK (kind IN ('revision', 'new_scope')),
        status TEXT NOT NULL DEFAULT 'open'
          CHECK (status IN ('open', 'resolved', 'wont_do')),
        timecode TEXT,
        resolved_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        FOREIGN KEY (work_item_id) REFERENCES work_items(id),
        FOREIGN KEY (version_id) REFERENCES work_item_versions(id)
      )
    ''');

    // Includes deleted rows so a number is never reused.
    await db.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS work_item_versions_sequence
      ON work_item_versions (work_item_id, sequence_no)
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS work_item_feedback_by_work_item
      ON work_item_feedback (work_item_id, status)
      WHERE deleted_at IS NULL
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS work_item_feedback_by_version
      ON work_item_feedback (version_id)
      WHERE version_id IS NOT NULL
    ''');
  }

  /// Work item multiplier (e.g. ×1.5 for rush jobs); existing rows get 1 and
  /// keep their totals. The column is checked first because an older build can
  /// lower the version number while leaving the column in place.
  static Future<void> _createVersion5(DatabaseExecutor db) async {
    final columns = await db.rawQuery('PRAGMA table_info(work_items)');
    final hasMultiplier = columns.any((row) => row['name'] == 'multiplier');
    if (!hasMultiplier) {
      await db.execute(
        'ALTER TABLE work_items ADD COLUMN multiplier REAL NOT NULL DEFAULT 1',
      );
    }
  }

  /// Links a payment to the work items it covers, for partial payments made by
  /// selecting work. Adds a table only; balances are still work total minus
  /// payments. `IF NOT EXISTS` for the same reason as version 4.
  static Future<void> _createVersion6(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS payment_allocations (
        id TEXT PRIMARY KEY,
        payment_id TEXT NOT NULL,
        work_item_id TEXT NOT NULL,
        amount REAL NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT,
        FOREIGN KEY (payment_id) REFERENCES payments(id),
        FOREIGN KEY (work_item_id) REFERENCES work_items(id)
      )
    ''');
    // A work item can be marked as paid only once.
    await db.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS payment_allocations_one_per_work_item
      ON payment_allocations (work_item_id)
      WHERE deleted_at IS NULL
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS payment_allocations_by_payment
      ON payment_allocations (payment_id)
      WHERE deleted_at IS NULL
    ''');
  }

  /// Drafts billed in parts: [billed_share] is the part of the full price a
  /// row bills (1 for normal work), [is_draft] marks a draft whose rest is
  /// billed later by a completion row that points to it through
  /// [completes_work_item_id]. Existing rows bill in full and keep their
  /// totals. Columns are checked first, as in version 5.
  static Future<void> _createVersion7(DatabaseExecutor db) async {
    final columns = (await db.rawQuery('PRAGMA table_info(work_items)'))
        .map((row) => row['name'])
        .toSet();
    if (!columns.contains('billed_share')) {
      await db.execute(
        'ALTER TABLE work_items ADD COLUMN billed_share REAL NOT NULL DEFAULT 1',
      );
    }
    if (!columns.contains('is_draft')) {
      await db.execute(
        'ALTER TABLE work_items ADD COLUMN is_draft INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (!columns.contains('completes_work_item_id')) {
      await db.execute(
        'ALTER TABLE work_items ADD COLUMN completes_work_item_id TEXT '
        'REFERENCES work_items(id)',
      );
    }
    // One completion per draft.
    await db.execute('''
      CREATE UNIQUE INDEX IF NOT EXISTS work_items_one_completion_per_draft
      ON work_items (completes_work_item_id)
      WHERE completes_work_item_id IS NOT NULL AND deleted_at IS NULL
    ''');
  }
}

enum BackupProblem { notFound, notABackup, newerVersion, corrupted }

class BackupValidationException implements Exception {
  const BackupValidationException(this.problem);

  final BackupProblem problem;

  @override
  String toString() => 'BackupValidationException(${problem.name})';
}

class BackupInfo {
  const BackupInfo({
    required this.schemaVersion,
    required this.clientCount,
    required this.workItemCount,
  });

  final int schemaVersion;
  final int clientCount;
  final int workItemCount;
}
