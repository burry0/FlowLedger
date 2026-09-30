import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/app_localizations.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/work_item_history.dart';
import 'package:flutter/material.dart';

/// Work item history, newest first.
class WorkItemHistoryList extends StatelessWidget {
  const WorkItemHistoryList({super.key, required this.events});

  final List<WorkItemHistoryEvent> events;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.revisionHistory, style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(l10n.historyLimitationNote, style: theme.textTheme.bodySmall),
        const SizedBox(height: 16),
        if (events.isEmpty)
          Text(l10n.historyEmpty)
        else
          for (var i = 0; i < events.length; i++)
            _HistoryRow(event: events[i], isLast: i == events.length - 1),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.event, required this.isLast});

  final WorkItemHistoryEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final detail = event.detail;
    final subject = event.subject;
    final isFeedbackEvent = detail != null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Icon(_icon(event.type), size: 18, color: colors.primary),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: colors.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatDateTime(event.at),
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      _title(l10n, event),
                      if (isFeedbackEvent && subject != null) subject,
                    ].join(' · '),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (detail != null)
                    Text(
                      detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _title(AppLocalizations l10n, WorkItemHistoryEvent event) {
  final subject = event.subject ?? '';
  return switch (event.type) {
    WorkItemHistoryEventType.workItemCreated => l10n.historyWorkItemCreated,
    WorkItemHistoryEventType.stepCompleted =>
      l10n.historyStepCompleted(subject),
    WorkItemHistoryEventType.workItemCompleted => l10n.historyWorkItemCompleted,
    WorkItemHistoryEventType.versionCreated =>
      l10n.historyVersionCreated(subject),
    WorkItemHistoryEventType.versionSent => l10n.historyVersionSent(subject),
    WorkItemHistoryEventType.versionApproved =>
      l10n.historyVersionApproved(subject),
    WorkItemHistoryEventType.revisionRequested => l10n.historyRevisionRequested,
    WorkItemHistoryEventType.newScopeRequested => l10n.historyNewScopeRequested,
    WorkItemHistoryEventType.feedbackResolved => l10n.historyFeedbackResolved,
    WorkItemHistoryEventType.feedbackWontDo => l10n.historyFeedbackWontDo,
  };
}

IconData _icon(WorkItemHistoryEventType type) => switch (type) {
      WorkItemHistoryEventType.workItemCreated => Icons.add_task_outlined,
      WorkItemHistoryEventType.stepCompleted => Icons.checklist_outlined,
      WorkItemHistoryEventType.workItemCompleted => Icons.task_alt_outlined,
      WorkItemHistoryEventType.versionCreated => Icons.layers_outlined,
      WorkItemHistoryEventType.versionSent => Icons.send_outlined,
      WorkItemHistoryEventType.versionApproved => Icons.verified_outlined,
      WorkItemHistoryEventType.revisionRequested => Icons.rate_review_outlined,
      WorkItemHistoryEventType.newScopeRequested => Icons.add_box_outlined,
      WorkItemHistoryEventType.feedbackResolved => Icons.check_circle_outline,
      WorkItemHistoryEventType.feedbackWontDo => Icons.block,
    };
