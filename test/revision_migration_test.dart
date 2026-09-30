import 'package:flowledger/repositories/payment_period_repository.dart';
import 'package:flowledger/repositories/revision_repository.dart';
import 'package:flowledger/repositories/work_item_repository.dart';
import 'package:flowledger/services/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/ledger_fixture.dart';
import 'support/test_database.dart';

void main() {
  late TestDatabase testDatabase;

  setUp(() async => testDatabase = await TestDatabase.create());
  tearDown(() async => testDatabase.dispose());

  test('fresh install creates the revision tables', () async {
    final db = await testDatabase.helper().database;
    expect(await db.getVersion(), DatabaseHelper.databaseVersion);
    final tables = (await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type IN ('table', 'index')"))
        .map((row) => row['name'])
        .toSet();
    expect(
      tables,
      containsAll(<String>[
        'work_item_versions',
        'work_item_feedback',
        'work_item_versions_sequence',
        'work_item_feedback_by_work_item',
        'work_item_feedback_by_version',
      ]),
    );
  });

  test('v3 database with data upgrades without loss and is backed up',
      () async {
    final v3 = testDatabase.helper(targetVersion: 3);
    final fixture = await LedgerFixture.seed(v3);
    final before = await snapshotLedgerTables(v3);
    final periodsBefore = await PaymentPeriodRepository(databaseHelper: v3)
        .getAllPeriodsWithTotals();
    await v3.close();

    final v4 = testDatabase.helper();
    final db = await v4.database;
    expect(await db.getVersion(), DatabaseHelper.databaseVersion);
    // v5 only adds work_items.multiplier (default 1); everything else must
    // match v3.
    final after = await snapshotLedgerTables(v4);
    expect(after['work_items']!.map((row) => row['multiplier']).toSet(), {1});
    for (final row in after['work_items']!) {
      row.remove('multiplier');
    }
    expect(after, before);

    final periodsAfter = await PaymentPeriodRepository(databaseHelper: v4)
        .getAllPeriodsWithTotals();
    expect(
      periodsAfter.map((p) => [
            p.period.id,
            p.totalWorkAmount,
            p.paymentAmount,
            p.remainingAmount,
            p.workItemCount,
          ]),
      periodsBefore.map((p) => [
            p.period.id,
            p.totalWorkAmount,
            p.paymentAmount,
            p.remainingAmount,
            p.workItemCount,
          ]),
    );
    expect(
      await WorkItemRepository(databaseHelper: v4)
          .getOpenPeriodTotal(fixture.clientId),
      1500,
    );

    // Existing work has an empty revision summary.
    final summaries = await RevisionRepository(databaseHelper: v4)
        .getSummaries([fixture.closedWorkItemId]);
    expect(summaries[fixture.closedWorkItemId]!.isEmpty, isTrue);

    // The backup is a complete v3 database.
    final backupPath = v4.lastBackupPath!;
    final backup = await databaseFactoryFfi.openDatabase(backupPath,
        options: OpenDatabaseOptions(readOnly: true));
    try {
      expect(await backup.getVersion(), 3);
      final backupWork = await backup.query('work_items', orderBy: 'id');
      expect(backupWork, before['work_items']);
      final backupTables = (await backup
              .rawQuery("SELECT name FROM sqlite_master WHERE type = 'table'"))
          .map((row) => row['name']);
      expect(backupTables, isNot(contains('work_item_versions')));
    } finally {
      await backup.close();
    }
  });

  test('CHECK constraints reject invalid status values', () async {
    final helper = testDatabase.helper();
    final fixture = await LedgerFixture.seed(helper);
    final db = await helper.database;
    final now = DateTime.now().toUtc().toIso8601String();
    await expectLater(
      db.insert('work_item_versions', {
        'id': 'bad',
        'work_item_id': fixture.closedWorkItemId,
        'sequence_no': 1,
        'label': 'V1',
        'status': 'unknown',
        'created_at': now,
        'updated_at': now,
      }),
      throwsA(isA<DatabaseException>()),
    );
  });

  test('revisions survive a downgrade and upgrade again', () async {
    final v4 = testDatabase.helper();
    final fixture = await LedgerFixture.seed(v4);
    final revisions = RevisionRepository(databaseHelper: v4);
    final version = await revisions.createVersion(fixture.closedWorkItemId);
    await revisions.createFeedback(fixture.closedWorkItemId,
        versionId: version.id, body: 'Yazıyı büyüt');
    await v4.close();

    // An old (v3) build has no onDowngrade; sqflite sets the version to 3.
    final old = testDatabase.helper(targetVersion: 3);
    expect(await (await old.database).getVersion(), 3);
    await old.close();

    final reopened = testDatabase.helper();
    expect(await (await reopened.database).getVersion(),
        DatabaseHelper.databaseVersion);
    final detail = await RevisionRepository(databaseHelper: reopened)
        .getRevisionDetail(fixture.closedWorkItemId);
    expect(detail!.versions.single.id, version.id);
    expect(detail.feedback.single.body, 'Yazıyı büyüt');
  });
}
