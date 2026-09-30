import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/work_item_revision_summary.dart';
import 'package:flowledger/widgets/revisions/revision_labels.dart';
import 'package:flutter/material.dart';

/// One-line revision summary on work item rows, e.g.
/// "V3 · Changes requested · 2 open revisions · 1 new scope request".
/// Draws nothing when the item has no revision records.
class RevisionSummaryLine extends StatelessWidget {
  const RevisionSummaryLine({super.key, required this.summary});

  final WorkItemRevisionSummary? summary;

  @override
  Widget build(BuildContext context) {
    final summary = this.summary;
    if (summary == null || summary.isEmpty) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final state = summary.state;
    final stateColor = deliverableStateColor(colors, state);
    final textStyle = Theme.of(context).textTheme.bodySmall;
    final parts = <String>[
      if (summary.latestLabel != null) summary.latestLabel!,
      deliverableStateLabel(l10n, state),
      if (summary.openRevisionCount > 0)
        l10n.openRevisionCount(summary.openRevisionCount),
      if (summary.openNewScopeCount > 0)
        l10n.openNewScopeCount(summary.openNewScopeCount),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: stateColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              parts.join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textStyle?.copyWith(color: colors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
