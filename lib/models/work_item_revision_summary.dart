import 'package:flowledger/models/work_item_version.dart';

/// Approval state of a deliverable, derived from versions and feedback (not
/// stored). Independent of the work item's status and amounts.
enum DeliverableState {
  noVersions,
  draft,
  waitingForFeedback,
  changesRequested,
  approved;

  /// Priority: approved > open revision > sent > draft. New-scope requests do
  /// not count.
  static DeliverableState derive({
    required WorkItemVersionStatus? latestStatus,
    required int openRevisionCount,
  }) {
    if (latestStatus == null) {
      return openRevisionCount > 0 ? changesRequested : noVersions;
    }
    if (latestStatus == WorkItemVersionStatus.approved) return approved;
    if (openRevisionCount > 0) return changesRequested;
    if (latestStatus == WorkItemVersionStatus.sent) return waitingForFeedback;
    return draft;
  }
}

/// Short revision summary shown on each work item in lists.
class WorkItemRevisionSummary {
  const WorkItemRevisionSummary({
    required this.workItemId,
    required this.versionCount,
    this.latestLabel,
    this.latestStatus,
    required this.openRevisionCount,
    required this.openNewScopeCount,
    required this.feedbackCount,
  });

  final String workItemId;
  final int versionCount;
  final String? latestLabel;
  final WorkItemVersionStatus? latestStatus;
  final int openRevisionCount;
  final int openNewScopeCount;
  final int feedbackCount;

  bool get isEmpty => versionCount == 0 && feedbackCount == 0;

  DeliverableState get state => DeliverableState.derive(
        latestStatus: latestStatus,
        openRevisionCount: openRevisionCount,
      );
}
