import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/core/work_item_labels.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/work_item.dart';
import 'package:flutter/material.dart';

/// Draft switch with a slider for the part of the full price billed now.
/// The rest is billed when the draft is completed.
class DraftShareField extends StatelessWidget {
  const DraftShareField({
    super.key,
    required this.isDraft,
    required this.share,
    required this.fullPrice,
    required this.onDraftChanged,
    required this.onShareChanged,
    this.locked = false,
  });

  static const defaultShare = 0.5;
  static const minShare = 0.05;
  static const maxShare = 0.95;

  final bool isDraft;
  final double share;

  /// Price × quantity × multiplier; null while the inputs are invalid.
  final double? fullPrice;
  final ValueChanged<bool> onDraftChanged;
  final ValueChanged<double> onShareChanged;

  /// The draft was already completed; its settings are shown read-only.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final fullPrice = this.fullPrice;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: isDraft,
          onChanged: locked ? null : onDraftChanged,
          title: Text(l10n.draftToggle),
          subtitle: Text(locked ? l10n.draftLockedNote : l10n.draftToggleHint),
        ),
        if (isDraft) ...[
          Slider(
            value: share.clamp(minShare, maxShare),
            min: minShare,
            max: maxShare,
            divisions: ((maxShare - minShare) * 100 / 5).round(),
            label: context.percent(share),
            onChanged: locked
                ? null
                // Snap to whole percent so totals stay readable.
                : (value) => onShareChanged((value * 100).round() / 100),
          ),
          Text(
            fullPrice == null
                ? context.percent(share)
                : l10n.draftShareSplit(
                    context.money(fullPrice * share),
                    context.percent(share),
                    context.money(fullPrice * (1 - share)),
                  ),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

String? workItemShareLabel(BuildContext context, WorkItem workItem) =>
    shareLabelFor(context.l10n, context.formatter, workItem);
