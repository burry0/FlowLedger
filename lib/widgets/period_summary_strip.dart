import 'package:flutter/material.dart';

class PeriodSummaryMetric {
  const PeriodSummaryMetric({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;

  /// Shown in the accent colour; usually only the balance due.
  final bool emphasized;
}

/// Divided summary strip: one row when wide, two per row when narrow.
class PeriodSummaryStrip extends StatelessWidget {
  const PeriodSummaryStrip({super.key, required this.metrics});

  final List<PeriodSummaryMetric> metrics;

  static const _stackBreakpoint = 560.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _stackBreakpoint) {
          return Wrap(
            runSpacing: 16,
            children: [
              for (final metric in metrics)
                SizedBox(
                  width: constraints.maxWidth / 2,
                  child: _MetricCell(metric: metric),
                ),
            ],
          );
        }
        final colors = Theme.of(context).colorScheme;
        return IntrinsicHeight(
          child: Row(
            children: [
              for (var i = 0; i < metrics.length; i++) ...[
                if (i > 0)
                  VerticalDivider(
                    width: 40,
                    thickness: 1,
                    color: colors.outlineVariant,
                  ),
                Expanded(child: _MetricCell(metric: metrics[i])),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MetricCell extends StatelessWidget {
  const _MetricCell({required this.metric});

  final PeriodSummaryMetric metric;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          metric.label,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 6),
        Text(
          metric.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: metric.emphasized ? theme.colorScheme.primary : null,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
