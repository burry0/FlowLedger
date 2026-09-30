import 'package:flowledger/models/payment_period.dart';
import 'package:flowledger/models/work_item.dart';
import 'package:flowledger/models/work_item_feedback.dart';
import 'package:flowledger/models/work_item_revision_summary.dart';
import 'package:flowledger/models/work_item_step.dart';
import 'package:flowledger/models/work_item_version.dart';

/// Everything the revisions screen loads at once.
class WorkItemRevisionDetail {
  const WorkItemRevisionDetail({
    required this.workItem,
    required this.clientName,
    required this.periodStatus,
    required this.steps,
    required this.allVersions,
    required this.feedback,
  });

  final WorkItem workItem;
  final String clientName;
  final PaymentPeriodStatus periodStatus;
  final List<WorkItemStep> steps;

  /// Newest first, including deleted versions so linked feedback can still
  /// show their label.
  final List<WorkItemVersion> allVersions;

  /// Feedback that is not deleted, newest first.
  final List<WorkItemFeedback> feedback;

  List<WorkItemVersion> get versions =>
      allVersions.where((version) => !version.isDeleted).toList();

  WorkItemVersion? get latestVersion {
    final active = versions;
    return active.isEmpty ? null : active.first;
  }

  WorkItemVersion? versionById(String? id) {
    if (id == null) return null;
    for (final version in allVersions) {
      if (version.id == id) return version;
    }
    return null;
  }

  int get openRevisionCount => feedback
      .where(
          (item) => item.isOpen && item.kind == WorkItemFeedbackKind.revision)
      .length;

  int get openNewScopeCount => feedback
      .where(
          (item) => item.isOpen && item.kind == WorkItemFeedbackKind.newScope)
      .length;

  DeliverableState get state => DeliverableState.derive(
        latestStatus: latestVersion?.status,
        openRevisionCount: openRevisionCount,
      );
}
