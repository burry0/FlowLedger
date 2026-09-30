import 'package:flowledger/models/payment_period.dart';
import 'package:flowledger/models/work_item.dart';
import 'package:flowledger/models/work_item_feedback.dart';
import 'package:flowledger/models/work_item_history.dart';
import 'package:flowledger/models/work_item_revision_detail.dart';
import 'package:flowledger/models/work_item_step.dart';
import 'package:flowledger/models/work_item_version.dart';
import 'package:flutter_test/flutter_test.dart';

DateTime t(int hour, int minute) => DateTime(2026, 9, 30, hour, minute);

WorkItem workItem({required WorkItemStatus status, DateTime? completedAt}) =>
    WorkItem(
      id: 'w',
      clientId: 'c',
      paymentPeriodId: 'p',
      title: 'Ana video',
      priceSnapshot: 100,
      quantity: 1,
      totalPrice: 100,
      status: status,
      completedAt: completedAt,
      createdAt: t(9, 0),
      updatedAt: t(9, 0),
    );

WorkItemVersion version(
  String id,
  int sequence,
  DateTime createdAt, {
  WorkItemVersionStatus status = WorkItemVersionStatus.draft,
  DateTime? sentAt,
  DateTime? approvedAt,
  DateTime? deletedAt,
}) =>
    WorkItemVersion(
      id: id,
      workItemId: 'w',
      sequenceNo: sequence,
      label: 'V$sequence',
      status: status,
      sentAt: sentAt,
      approvedAt: approvedAt,
      createdAt: createdAt,
      updatedAt: createdAt,
      deletedAt: deletedAt,
    );

WorkItemFeedback feedback(
  String id,
  DateTime createdAt, {
  String? versionId,
  WorkItemFeedbackKind kind = WorkItemFeedbackKind.revision,
  WorkItemFeedbackStatus status = WorkItemFeedbackStatus.open,
  DateTime? resolvedAt,
}) =>
    WorkItemFeedback(
      id: id,
      workItemId: 'w',
      versionId: versionId,
      body: 'Talep $id',
      kind: kind,
      status: status,
      resolvedAt: resolvedAt,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

void main() {
  test('builds the sample flow newest first', () {
    final detail = WorkItemRevisionDetail(
      workItem: workItem(status: WorkItemStatus.inProgress),
      clientName: 'Müşteri',
      periodStatus: PaymentPeriodStatus.open,
      steps: const [],
      allVersions: [
        version('v3', 3, t(15, 18),
            status: WorkItemVersionStatus.approved, approvedAt: t(15, 20)),
        version('v2', 2, t(14, 20),
            status: WorkItemVersionStatus.sent, sentAt: t(14, 25)),
      ],
      feedback: [
        feedback('f1', t(14, 32),
            versionId: 'v2',
            status: WorkItemFeedbackStatus.resolved,
            resolvedAt: t(15, 10)),
      ],
    );

    final events = buildWorkItemHistory(detail);
    expect(events.map((e) => (e.type, e.at)).toList(), [
      (WorkItemHistoryEventType.versionApproved, t(15, 20)),
      (WorkItemHistoryEventType.versionCreated, t(15, 18)),
      (WorkItemHistoryEventType.feedbackResolved, t(15, 10)),
      (WorkItemHistoryEventType.revisionRequested, t(14, 32)),
      (WorkItemHistoryEventType.versionSent, t(14, 25)),
      (WorkItemHistoryEventType.versionCreated, t(14, 20)),
      (WorkItemHistoryEventType.workItemCreated, t(9, 0)),
    ]);
    expect(events[2].subject, 'V2');
    expect(events[2].detail, 'Talep f1');
    // V3 was never marked sent, so no event is invented.
    expect(
      events.where((e) =>
          e.type == WorkItemHistoryEventType.versionSent && e.subject == 'V3'),
      isEmpty,
    );
  });

  test('skips records without timestamps and deleted records', () {
    final detail = WorkItemRevisionDetail(
      workItem: workItem(status: WorkItemStatus.inProgress),
      clientName: 'Müşteri',
      periodStatus: PaymentPeriodStatus.closed,
      steps: [
        WorkItemStep(
          id: 's1',
          workItemId: 'w',
          title: 'Renk',
          sortOrder: 0,
          isDone: true,
          completedAt: t(10, 0),
          createdAt: t(9, 0),
          updatedAt: t(10, 0),
        ),
        WorkItemStep(
          id: 's2',
          workItemId: 'w',
          title: 'Ses',
          sortOrder: 1,
          createdAt: t(9, 0),
          updatedAt: t(9, 0),
        ),
      ],
      allVersions: [
        version('v1', 1, t(11, 0), deletedAt: t(12, 0)),
      ],
      feedback: [
        feedback('f1', t(11, 30), versionId: 'v1'),
        feedback('f2', t(11, 40),
            kind: WorkItemFeedbackKind.newScope,
            status: WorkItemFeedbackStatus.wontDo,
            resolvedAt: t(11, 50)),
        // A stale resolvedAt on open feedback is not a closing event.
        feedback('f3', t(11, 45), resolvedAt: t(11, 55)),
      ],
    );

    final types = buildWorkItemHistory(detail).map((e) => e.type).toList();
    expect(types, [
      WorkItemHistoryEventType.feedbackWontDo,
      WorkItemHistoryEventType.revisionRequested,
      WorkItemHistoryEventType.newScopeRequested,
      WorkItemHistoryEventType.revisionRequested,
      WorkItemHistoryEventType.stepCompleted,
      WorkItemHistoryEventType.workItemCreated,
    ]);
    // No event for the deleted version, but its feedback keeps the label.
    final history = buildWorkItemHistory(detail);
    expect(
        history.any((e) => e.type == WorkItemHistoryEventType.versionCreated),
        isFalse);
    expect(history.firstWhere((e) => e.detail == 'Talep f1').subject, 'V1');
  });

  test('completed work has a completion event', () {
    final detail = WorkItemRevisionDetail(
      workItem:
          workItem(status: WorkItemStatus.completed, completedAt: t(18, 0)),
      clientName: 'Müşteri',
      periodStatus: PaymentPeriodStatus.open,
      steps: const [],
      allVersions: const [],
      feedback: const [],
    );
    expect(buildWorkItemHistory(detail).map((e) => e.type), [
      WorkItemHistoryEventType.workItemCompleted,
      WorkItemHistoryEventType.workItemCreated,
    ]);
  });
}
