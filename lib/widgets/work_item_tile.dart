import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/work_item.dart';
import 'package:flowledger/models/work_item_revision_summary.dart';
import 'package:flowledger/models/work_item_step.dart';
import 'package:flowledger/repositories/work_item_repository.dart';
import 'package:flowledger/widgets/revisions/revision_summary_line.dart';
import 'package:flutter/material.dart';

/// A label/value pair shown in the expanded part of a [WorkItemTile].
typedef WorkItemMetric = ({String label, String value});

/// Expandable row for a single work item: summary line, metrics, stages and
/// actions. Used on the client page and on the works list.
class WorkItemTile extends StatefulWidget {
  const WorkItemTile({
    super.key,
    required this.workItem,
    required this.repository,
    required this.subtitle,
    required this.metrics,
    required this.revisionSummary,
    required this.onOpenRevisions,
    required this.onStepChanged,
    this.stepsEditable = true,
    this.onEdit,
    this.onDelete,
    this.onMarkCompleted,
  });

  final WorkItem workItem;
  final WorkItemRepository repository;
  final String subtitle;
  final List<WorkItemMetric> metrics;
  final WorkItemRevisionSummary? revisionSummary;
  final VoidCallback onOpenRevisions;
  final void Function(WorkItemStep step, bool isDone) onStepChanged;

  /// Stages are read-only for completed work and for closed periods.
  final bool stepsEditable;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onMarkCompleted;

  @override
  State<WorkItemTile> createState() => _WorkItemTileState();
}

class _WorkItemTileState extends State<WorkItemTile> {
  late Future<List<WorkItemStep>> _steps;

  @override
  void initState() {
    super.initState();
    _steps = _loadSteps();
  }

  @override
  void didUpdateWidget(WorkItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Parents reload their work items after every change, so a new instance
    // means the stages may have changed too.
    if (!identical(oldWidget.workItem, widget.workItem)) {
      _steps = _loadSteps();
    }
  }

  Future<List<WorkItemStep>> _loadSteps() =>
      widget.repository.getStepsForWorkItem(widget.workItem.id);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final workItem = widget.workItem;
    final notes = workItem.notes;
    final isCompleted = workItem.status == WorkItemStatus.completed;
    final canEditSteps = widget.stepsEditable && !isCompleted;

    return ExpansionTile(
      shape: const Border(),
      collapsedShape: const Border(),
      leading: Icon(
        isCompleted ? Icons.check_circle_outline : Icons.pending_actions,
      ),
      title: Text(workItem.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.subtitle),
          RevisionSummaryLine(summary: widget.revisionSummary),
        ],
      ),
      trailing: Text(
        context.money(workItem.totalPrice),
        style: theme.textTheme.titleSmall,
      ),
      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 20,
          runSpacing: 8,
          children: [
            for (final metric in widget.metrics)
              _Metric(label: metric.label, value: metric.value),
          ],
        ),
        if (notes != null && notes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(notes),
        ],
        const SizedBox(height: 12),
        FutureBuilder<List<WorkItemStep>>(
          future: _steps,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator(),
              );
            }
            final steps = snapshot.data ?? const <WorkItemStep>[];
            final doneCount = steps.where((step) => step.isDone).length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.workStages}: ${l10n.stagesProgress(doneCount, steps.length)}',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                if (steps.isEmpty)
                  Text(l10n.noStagesForWork, style: theme.textTheme.bodySmall)
                else
                  for (final step in steps)
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: step.isDone,
                      onChanged: canEditSteps
                          ? (value) =>
                              widget.onStepChanged(step, value ?? false)
                          : null,
                      title: Text(step.title),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: 8,
          runSpacing: 4,
          children: [
            TextButton.icon(
              onPressed: widget.onOpenRevisions,
              icon: const Icon(Icons.layers_outlined),
              label: Text(l10n.revisions),
            ),
            if (widget.onEdit != null)
              TextButton.icon(
                onPressed: widget.onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.edit),
              ),
            if (widget.onDelete != null)
              TextButton.icon(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.delete),
              ),
            if (!isCompleted && widget.onMarkCompleted != null)
              FilledButton.icon(
                onPressed: widget.onMarkCompleted,
                icon: const Icon(Icons.check_circle_outline),
                label: Text(l10n.markAsCompleted),
              ),
          ],
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelMedium),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
