import 'package:flowledger/models/payment_period.dart';
import 'package:flowledger/models/work_item_feedback.dart';
import 'package:flowledger/models/work_item_revision_summary.dart';
import 'package:flowledger/models/work_item_version.dart';
import 'package:flowledger/repositories/revision_repository.dart';
import 'package:flowledger/repositories/work_item_repository.dart';
import 'package:flowledger/services/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ledger_fixture.dart';
import 'support/test_database.dart';

void main() {
  late TestDatabase testDatabase;
  late DatabaseHelper helper;
  late LedgerFixture fixture;
  late RevisionRepository revisions;

  setUp(() async {
    testDatabase = await TestDatabase.create();
    helper = testDatabase.helper();
    fixture = await LedgerFixture.seed(helper);
    revisions = RevisionRepository(databaseHelper: helper);
  });
  tearDown(() async => testDatabase.dispose());

  test('version numbers are not reused after delete', () async {
    final id = fixture.openInProgressWorkItemId;
    final v1 = await revisions.createVersion(id);
    final v2 = await revisions.createVersion(id, notes: '  Renk düzeltildi ');
    expect(v1.label, 'V1');
    expect(v2.sequenceNo, 2);
    expect(v2.notes, 'Renk düzeltildi');

    await revisions.softDeleteVersion(v2.id);
    final v3 = await revisions.createVersion(id, label: 'Final');
    expect(v3.sequenceNo, 3);
    expect(v3.label, 'Final');

    final detail = (await revisions.getRevisionDetail(id))!;
    expect(detail.versions.map((v) => v.label), ['Final', 'V1']);
    expect(detail.allVersions, hasLength(3));
    expect(detail.latestVersion!.id, v3.id);
  });

  test('versions and feedback can be added to closed-period work', () async {
    final id = fixture.closedWorkItemId;
    final detailBefore = (await revisions.getRevisionDetail(id))!;
    expect(detailBefore.periodStatus, PaymentPeriodStatus.closed);

    final version = await revisions.createVersion(id);
    await revisions.setVersionStatus(version.id, WorkItemVersionStatus.sent);
    final feedback = await revisions.createFeedback(
      id,
      versionId: version.id,
      body: 'Intro müziği biraz daha geç girsin.',
      timecode: '00:12',
    );
    await revisions.setFeedbackStatus(
        feedback.id, WorkItemFeedbackStatus.resolved);

    final detail = (await revisions.getRevisionDetail(id))!;
    expect(detail.latestVersion!.status, WorkItemVersionStatus.sent);
    expect(detail.feedback.single.status, WorkItemFeedbackStatus.resolved);
    expect(detail.feedback.single.timecode, '00:12');
  });

  test('revision operations never touch financial or work records', () async {
    final before = await snapshotLedgerTables(helper);
    final workItems = WorkItemRepository(databaseHelper: helper);
    final openTotalBefore =
        await workItems.getOpenPeriodTotal(fixture.clientId);
    final unpaidBefore = await workItems.getDashboardTotalUnpaid();

    for (final id in [
      fixture.closedWorkItemId,
      fixture.openCompletedWorkItemId,
      fixture.openInProgressWorkItemId,
    ]) {
      final v1 = await revisions.createVersion(id, link: 'D:/export/v1.mp4');
      await revisions.setVersionStatus(v1.id, WorkItemVersionStatus.sent);
      final f = await revisions.createFeedback(id,
          versionId: v1.id, body: 'Yazıyı büyüt');
      await revisions.createFeedback(id,
          body: '9:16 versiyonu da yapalım',
          kind: WorkItemFeedbackKind.newScope);
      await revisions.setFeedbackStatus(f.id, WorkItemFeedbackStatus.resolved);
      final v2 = await revisions.createVersion(id);
      await revisions.setVersionStatus(v2.id, WorkItemVersionStatus.approved);
      await revisions.updateVersion(v2.id, label: 'Final', notes: 'Onaylandı');
      await revisions.softDeleteVersion(v1.id);
      await revisions.softDeleteFeedback(f.id);
    }

    expect(await snapshotLedgerTables(helper), before);
    expect(
        await workItems.getOpenPeriodTotal(fixture.clientId), openTotalBefore);
    expect(await workItems.getDashboardTotalUnpaid(), unpaidBefore);
  });

  test('feedback linked to a deleted version is kept', () async {
    final id = fixture.openCompletedWorkItemId;
    final version = await revisions.createVersion(id);
    final feedback = await revisions.createFeedback(id,
        versionId: version.id, body: '00:43 yazıyı küçült');
    await revisions.softDeleteVersion(version.id);

    final detail = (await revisions.getRevisionDetail(id))!;
    expect(detail.versions, isEmpty);
    final kept = detail.feedback.single;
    expect(kept.id, feedback.id);
    expect(kept.versionId, version.id);
    expect(detail.versionById(kept.versionId)!.isDeleted, isTrue);

    // New feedback cannot link to a deleted version, but an existing link
    // can be kept when editing.
    await expectLater(
      revisions.createFeedback(id, versionId: version.id, body: 'x'),
      throwsStateError,
    );
    await revisions.updateFeedback(kept.id,
        body: 'Yazıyı küçült',
        kind: WorkItemFeedbackKind.revision,
        versionId: version.id);
    final updated = (await revisions.getRevisionDetail(id))!.feedback.single;
    expect(updated.body, 'Yazıyı küçült');
    expect(updated.versionId, version.id);
  });

  test('feedback is resolved, declined and reopened', () async {
    final id = fixture.openInProgressWorkItemId;
    final feedback = await revisions.createFeedback(id, body: 'Rengi ısıt');

    await revisions.setFeedbackStatus(
        feedback.id, WorkItemFeedbackStatus.resolved);
    var current = (await revisions.getRevisionDetail(id))!.feedback.single;
    expect(current.resolvedAt, isNotNull);

    await revisions.setFeedbackStatus(feedback.id, WorkItemFeedbackStatus.open);
    current = (await revisions.getRevisionDetail(id))!.feedback.single;
    expect(current.status, WorkItemFeedbackStatus.open);
    expect(current.resolvedAt, isNull);

    await revisions.setFeedbackStatus(
        feedback.id, WorkItemFeedbackStatus.wontDo);
    current = (await revisions.getRevisionDetail(id))!.feedback.single;
    expect(current.status, WorkItemFeedbackStatus.wontDo);
    expect(current.resolvedAt, isNotNull);
  });

  test('status timestamps are never invented and are cleared on undo',
      () async {
    final id = fixture.openInProgressWorkItemId;
    final version = await revisions.createVersion(id);

    await revisions.setVersionStatus(
        version.id, WorkItemVersionStatus.approved);
    var current = (await revisions.getRevisionDetail(id))!.latestVersion!;
    expect(current.approvedAt, isNotNull);
    expect(current.sentAt, isNull, reason: 'gönderim hiç kaydedilmedi');

    await revisions.setVersionStatus(version.id, WorkItemVersionStatus.sent);
    current = (await revisions.getRevisionDetail(id))!.latestVersion!;
    expect(current.sentAt, isNotNull);
    expect(current.approvedAt, isNull);

    await revisions.setVersionStatus(version.id, WorkItemVersionStatus.draft);
    current = (await revisions.getRevisionDetail(id))!.latestVersion!;
    expect(current.sentAt, isNull);
  });

  test('batched summaries have correct counts and state', () async {
    final a = fixture.openInProgressWorkItemId;
    final b = fixture.openCompletedWorkItemId;
    final c = fixture.closedWorkItemId;

    final va = await revisions.createVersion(a);
    await revisions.setVersionStatus(va.id, WorkItemVersionStatus.sent);
    await revisions.createFeedback(a, versionId: va.id, body: 'Revizyon');
    await revisions.createFeedback(a,
        body: 'Ek istek', kind: WorkItemFeedbackKind.newScope);

    final vb = await revisions.createVersion(b);
    await revisions.setVersionStatus(vb.id, WorkItemVersionStatus.sent);
    final vb2 = await revisions.createVersion(b, label: 'Final');
    await revisions.setVersionStatus(vb2.id, WorkItemVersionStatus.approved);
    await revisions.createFeedback(b,
        body: 'Sonra', kind: WorkItemFeedbackKind.newScope);

    final summaries = await revisions.getSummaries([a, b, c, a]);
    expect(summaries.keys.toSet(), {a, b, c});

    expect(summaries[a]!.versionCount, 1);
    expect(summaries[a]!.openRevisionCount, 1);
    expect(summaries[a]!.openNewScopeCount, 1);
    expect(summaries[a]!.state, DeliverableState.changesRequested);

    expect(summaries[b]!.latestLabel, 'Final');
    expect(summaries[b]!.versionCount, 2);
    expect(summaries[b]!.state, DeliverableState.approved);

    expect(summaries[c]!.isEmpty, isTrue);
    expect(summaries[c]!.state, DeliverableState.noVersions);

    expect(await revisions.getSummaries(const []), isEmpty);
  });

  test('derived state priority', () {
    DeliverableState derive(WorkItemVersionStatus? s, int open) =>
        DeliverableState.derive(latestStatus: s, openRevisionCount: open);
    expect(derive(null, 0), DeliverableState.noVersions);
    expect(derive(null, 1), DeliverableState.changesRequested);
    expect(derive(WorkItemVersionStatus.draft, 0), DeliverableState.draft);
    expect(derive(WorkItemVersionStatus.sent, 0),
        DeliverableState.waitingForFeedback);
    expect(derive(WorkItemVersionStatus.sent, 2),
        DeliverableState.changesRequested);
    expect(
        derive(WorkItemVersionStatus.approved, 2), DeliverableState.approved);
  });

  test('cannot link to deleted work or another item\'s version', () async {
    final a = fixture.openInProgressWorkItemId;
    final b = fixture.openCompletedWorkItemId;
    final foreign = await revisions.createVersion(b);
    await expectLater(
      revisions.createFeedback(a, versionId: foreign.id, body: 'x'),
      throwsArgumentError,
    );

    await WorkItemRepository(databaseHelper: helper).softDeleteWorkItem(a);
    await expectLater(revisions.createVersion(a), throwsStateError);
    expect(await revisions.getRevisionDetail(a), isNull);
  });

  test('empty feedback and version labels are rejected', () async {
    final id = fixture.openInProgressWorkItemId;
    await expectLater(
        revisions.createFeedback(id, body: '   '), throwsArgumentError);
    final version = await revisions.createVersion(id, label: '  ');
    expect(version.label, 'V1');
    await expectLater(
        revisions.updateVersion(version.id, label: ' '), throwsArgumentError);
  });

  test('unknown enum values throw', () {
    expect(() => WorkItemVersionStatus.fromDatabase('rejected'),
        throwsFormatException);
    expect(
        () => WorkItemFeedbackKind.fromDatabase('bug'), throwsFormatException);
    expect(() => WorkItemFeedbackStatus.fromDatabase('in_progress'),
        throwsFormatException);
  });
}
