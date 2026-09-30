import 'package:flowledger/models/work_item.dart';
import 'package:flowledger/models/work_item_feedback.dart';
import 'package:flowledger/models/work_item_revision_detail.dart';

enum WorkItemHistoryEventType {
  workItemCreated,
  stepCompleted,
  workItemCompleted,
  versionCreated,
  versionSent,
  versionApproved,
  revisionRequested,
  newScopeRequested,
  feedbackResolved,
  feedbackWontDo,
}

class WorkItemHistoryEvent {
  const WorkItemHistoryEvent({
    required this.at,
    required this.type,
    this.subject,
    this.detail,
  });

  final DateTime at;
  final WorkItemHistoryEventType type;

  /// Version label or stage title.
  final String? subject;

  /// Extra detail, such as the feedback text.
  final String? detail;
}

/// Builds a work item's history from the timestamps of existing records;
/// there is no event table. Only the latest time of each status is known and
/// deleted records are skipped, so this is not a full audit log.
List<WorkItemHistoryEvent> buildWorkItemHistory(WorkItemRevisionDetail detail) {
  final events = <WorkItemHistoryEvent>[];
  final workItem = detail.workItem;

  events.add(WorkItemHistoryEvent(
    at: workItem.createdAt,
    type: WorkItemHistoryEventType.workItemCreated,
    subject: workItem.title,
  ));
  for (final step in detail.steps) {
    final completedAt = step.completedAt;
    if (step.isDone && completedAt != null) {
      events.add(WorkItemHistoryEvent(
        at: completedAt,
        type: WorkItemHistoryEventType.stepCompleted,
        subject: step.title,
      ));
    }
  }
  final completedAt = workItem.completedAt;
  if (workItem.status == WorkItemStatus.completed && completedAt != null) {
    events.add(WorkItemHistoryEvent(
      at: completedAt,
      type: WorkItemHistoryEventType.workItemCompleted,
    ));
  }

  for (final version in detail.versions) {
    events.add(WorkItemHistoryEvent(
      at: version.createdAt,
      type: WorkItemHistoryEventType.versionCreated,
      subject: version.label,
    ));
    final sentAt = version.sentAt;
    if (sentAt != null) {
      events.add(WorkItemHistoryEvent(
        at: sentAt,
        type: WorkItemHistoryEventType.versionSent,
        subject: version.label,
      ));
    }
    final approvedAt = version.approvedAt;
    if (approvedAt != null) {
      events.add(WorkItemHistoryEvent(
        at: approvedAt,
        type: WorkItemHistoryEventType.versionApproved,
        subject: version.label,
      ));
    }
  }

  for (final feedback in detail.feedback) {
    final versionLabel = detail.versionById(feedback.versionId)?.label;
    events.add(WorkItemHistoryEvent(
      at: feedback.createdAt,
      type: feedback.kind == WorkItemFeedbackKind.newScope
          ? WorkItemHistoryEventType.newScopeRequested
          : WorkItemHistoryEventType.revisionRequested,
      subject: versionLabel,
      detail: feedback.body,
    ));
    final resolvedAt = feedback.resolvedAt;
    if (resolvedAt != null && feedback.status != WorkItemFeedbackStatus.open) {
      events.add(WorkItemHistoryEvent(
        at: resolvedAt,
        type: feedback.status == WorkItemFeedbackStatus.wontDo
            ? WorkItemHistoryEventType.feedbackWontDo
            : WorkItemHistoryEventType.feedbackResolved,
        subject: versionLabel,
        detail: feedback.body,
      ));
    }
  }

  // Newest first; ties keep creation order.
  final indexed = events.asMap().entries.toList()
    ..sort((a, b) {
      final byTime = b.value.at.compareTo(a.value.at);
      return byTime != 0 ? byTime : b.key.compareTo(a.key);
    });
  return [for (final entry in indexed) entry.value];
}
