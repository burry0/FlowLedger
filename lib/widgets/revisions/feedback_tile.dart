import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/work_item_feedback.dart';
import 'package:flowledger/widgets/revisions/revision_labels.dart';
import 'package:flutter/material.dart';

enum _FeedbackAction { edit, wontDo, reopen, delete }

/// One feedback row. The leading button resolves or reopens it; other
/// actions are in the menu.
class FeedbackTile extends StatelessWidget {
  const FeedbackTile({
    super.key,
    required this.feedback,
    required this.versionLabel,
    required this.onStatusChanged,
    required this.onEdit,
    required this.onDelete,
  });

  final WorkItemFeedback feedback;

  /// Label of the linked version, or "General".
  final String versionLabel;
  final ValueChanged<WorkItemFeedbackStatus> onStatusChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isOpen = feedback.isOpen;
    final isNewScope = feedback.kind == WorkItemFeedbackKind.newScope;
    final timecode = feedback.timecode;
    final kindColor = isNewScope ? colors.secondary : colors.tertiary;

    final metaParts = <String>[
      versionLabel,
      formatDateTime(feedback.createdAt),
      if (!isOpen) feedbackStatusLabel(l10n, feedback.status),
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              tooltip: isOpen ? l10n.markResolved : l10n.reopen,
              onPressed: () => onStatusChanged(
                isOpen
                    ? WorkItemFeedbackStatus.resolved
                    : WorkItemFeedbackStatus.open,
              ),
              icon: Icon(
                switch (feedback.status) {
                  WorkItemFeedbackStatus.open => Icons.radio_button_unchecked,
                  WorkItemFeedbackStatus.resolved => Icons.check_circle,
                  WorkItemFeedbackStatus.wontDo => Icons.block,
                },
                color: isOpen ? kindColor : colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          feedbackKindLabel(l10n, feedback.kind),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: kindColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (timecode != null)
                          Text(
                            timecode,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feedback.body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isOpen ? null : colors.onSurfaceVariant,
                        decoration:
                            feedback.status == WorkItemFeedbackStatus.resolved
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metaParts.join(' · '),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            PopupMenuButton<_FeedbackAction>(
              onSelected: (action) => switch (action) {
                _FeedbackAction.edit => onEdit(),
                _FeedbackAction.wontDo =>
                  onStatusChanged(WorkItemFeedbackStatus.wontDo),
                _FeedbackAction.reopen =>
                  onStatusChanged(WorkItemFeedbackStatus.open),
                _FeedbackAction.delete => onDelete(),
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _FeedbackAction.edit,
                  child: Text(l10n.edit),
                ),
                if (isOpen)
                  PopupMenuItem(
                    value: _FeedbackAction.wontDo,
                    child: Text(l10n.markWontDo),
                  )
                else
                  PopupMenuItem(
                    value: _FeedbackAction.reopen,
                    child: Text(l10n.reopen),
                  ),
                PopupMenuItem(
                  value: _FeedbackAction.delete,
                  child: Text(l10n.delete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
