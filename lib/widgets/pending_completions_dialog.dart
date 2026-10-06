import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/pending_completion.dart';
import 'package:flutter/material.dart';

/// Lists drafts waiting for completion. Completing one removes it from the
/// list; the dialog closes by itself when none are left.
class PendingCompletionsDialog extends StatefulWidget {
  const PendingCompletionsDialog({
    super.key,
    required this.pending,
    required this.onComplete,
  });

  final List<PendingCompletion> pending;

  /// Asks for confirmation and completes the draft; true when it was done.
  final Future<bool> Function(PendingCompletion pending) onComplete;

  @override
  State<PendingCompletionsDialog> createState() =>
      _PendingCompletionsDialogState();
}

class _PendingCompletionsDialogState extends State<PendingCompletionsDialog> {
  late final List<PendingCompletion> _pending = [...widget.pending];
  String? _completingId;

  Future<void> _complete(PendingCompletion pending) async {
    setState(() => _completingId = pending.draft.id);
    final done = await widget.onComplete(pending);
    if (!mounted) return;
    setState(() {
      _completingId = null;
      if (done) {
        _pending.removeWhere((p) => p.draft.id == pending.draft.id);
      }
    });
    if (_pending.isEmpty) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(l10n.pendingCompletionsTitle),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.pendingCompletionsNote, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _pending.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
                itemBuilder: (context, index) {
                  final pending = _pending[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(pending.draft.title),
                    subtitle: Text(
                      '${l10n.pendingCompletionSubtitle(
                        formatDate(pending.periodStartDate),
                        context.percent(pending.billedShare),
                      )}\n${context.money(pending.remainingAmount)}',
                    ),
                    isThreeLine: true,
                    trailing: FilledButton.tonal(
                      onPressed: _completingId == null
                          ? () => _complete(pending)
                          : null,
                      child: Text(l10n.completeDraftAction),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}
