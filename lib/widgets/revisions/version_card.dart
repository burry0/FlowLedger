import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/work_item_version.dart';
import 'package:flowledger/widgets/revisions/revision_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One version. The latest starts expanded, older ones collapsed.
class VersionCard extends StatelessWidget {
  const VersionCard({
    super.key,
    required this.version,
    required this.isLatest,
    required this.onStatusChanged,
    required this.onEdit,
    required this.onDelete,
    this.feedbackSummary,
    this.onAddFeedback,
  });

  final WorkItemVersion version;
  final bool isLatest;
  final ValueChanged<WorkItemVersionStatus> onStatusChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Short feedback count, e.g. "2 open · 5 total".
  final String? feedbackSummary;
  final VoidCallback? onAddFeedback;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final notes = version.notes;
    final link = version.link;
    final subtitleParts = [
      versionStatusLabel(l10n, version.status),
      formatDateTime(version.createdAt),
      if (feedbackSummary != null) feedbackSummary!,
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        key: PageStorageKey('version-${version.id}'),
        initiallyExpanded: isLatest,
        leading: Icon(_statusIcon(version.status)),
        title: Row(
          children: [
            Flexible(
              child: Text(
                version.label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (isLatest) ...[
              const SizedBox(width: 8),
              _Badge(label: l10n.latestVersion),
            ],
          ],
        ),
        subtitle: Text(subtitleParts.join(' · ')),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<WorkItemVersionStatus>(
            showSelectedIcon: false,
            segments: [
              for (final status in WorkItemVersionStatus.values)
                ButtonSegment(
                  value: status,
                  icon: Icon(_statusIcon(status), size: 18),
                  label: Text(versionStatusLabel(l10n, status)),
                ),
            ],
            selected: {version.status},
            onSelectionChanged: (selection) =>
                onStatusChanged(selection.single),
          ),
          if (notes != null) ...[
            const SizedBox(height: 12),
            Text(notes),
          ],
          if (link != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.link, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(child: SelectableText(link, maxLines: 2)),
                IconButton(
                  tooltip: l10n.copyLink,
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: link));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.linkCopied)),
                    );
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 4,
            children: [
              if (onAddFeedback != null)
                TextButton.icon(
                  onPressed: onAddFeedback,
                  icon: const Icon(Icons.add_comment_outlined),
                  label: Text(l10n.addFeedback),
                ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.edit),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.delete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

IconData _statusIcon(WorkItemVersionStatus status) => switch (status) {
      WorkItemVersionStatus.draft => Icons.edit_note_outlined,
      WorkItemVersionStatus.sent => Icons.send_outlined,
      WorkItemVersionStatus.approved => Icons.verified_outlined,
    };

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: colors.onPrimaryContainer),
      ),
    );
  }
}
