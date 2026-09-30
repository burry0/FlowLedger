import 'package:flowledger/core/app_refresh_notifier.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/payment_period.dart';
import 'package:flowledger/models/work_item_feedback.dart';
import 'package:flowledger/models/work_item_history.dart';
import 'package:flowledger/models/work_item_revision_detail.dart';
import 'package:flowledger/models/work_item_version.dart';
import 'package:flowledger/repositories/revision_repository.dart';
import 'package:flowledger/widgets/revisions/feedback_dialog.dart';
import 'package:flowledger/widgets/revisions/feedback_tile.dart';
import 'package:flowledger/widgets/revisions/revision_labels.dart';
import 'package:flowledger/widgets/revisions/version_card.dart';
import 'package:flowledger/widgets/revisions/version_dialog.dart';
import 'package:flowledger/widgets/revisions/work_item_history_list.dart';
import 'package:flutter/material.dart';

/// Versions, feedback and history of one work item.
///
/// Amounts, status, stages and payments are not edited here. Everything on
/// this screen also works for closed periods and never changes financial
/// records.
class WorkItemRevisionsScreen extends StatefulWidget {
  const WorkItemRevisionsScreen({
    super.key,
    required this.workItemId,
    required this.title,
    this.repository,
  });

  final String workItemId;
  final String title;

  /// Overridable for tests.
  final RevisionRepository? repository;

  static Future<void> open(
    BuildContext context, {
    required String workItemId,
    required String title,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            WorkItemRevisionsScreen(workItemId: workItemId, title: title),
      ),
    );
  }

  @override
  State<WorkItemRevisionsScreen> createState() =>
      _WorkItemRevisionsScreenState();
}

class _WorkItemRevisionsScreenState extends State<WorkItemRevisionsScreen> {
  static const _wideLayoutBreakpoint = 900.0;

  late final RevisionRepository _repository =
      widget.repository ?? RevisionRepository();
  late Future<WorkItemRevisionDetail?> _detailFuture;
  var _isSaving = false;
  var _showAllFeedback = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = _repository.getRevisionDetail(widget.workItemId);
    AppRefreshNotifier.revision.addListener(_reload);
  }

  @override
  void dispose() {
    AppRefreshNotifier.revision.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    setState(() {
      _detailFuture = _repository.getRevisionDetail(widget.workItemId);
    });
  }

  /// Runs a write, then reloads and notifies other screens, or shows an error.
  Future<void> _run(Future<void> Function() action) async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await action();
      AppRefreshNotifier.notifyChanged();
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.revisionSaveFailed)),
        );
      }
      _reload();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _createVersion(WorkItemRevisionDetail detail) async {
    final nextSequence = detail.allVersions.isEmpty
        ? 1
        : detail.allVersions
                .map((version) => version.sequenceNo)
                .reduce((a, b) => a > b ? a : b) +
            1;
    final result = await showDialog<VersionDialogResult>(
      context: context,
      builder: (context) => VersionDialog(defaultLabel: 'V$nextSequence'),
    );
    if (result == null) return;
    await _run(() => _repository.createVersion(
          widget.workItemId,
          label: result.label,
          notes: result.notes,
          link: result.link,
        ));
  }

  Future<void> _editVersion(WorkItemVersion version) async {
    final result = await showDialog<VersionDialogResult>(
      context: context,
      builder: (context) =>
          VersionDialog(version: version, defaultLabel: version.label),
    );
    if (result == null) return;
    await _run(() => _repository.updateVersion(
          version.id,
          label: result.label ?? version.label,
          notes: result.notes,
          link: result.link,
        ));
  }

  Future<void> _deleteVersion(WorkItemVersion version) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.deleteVersionConfirm(version.label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(() => _repository.softDeleteVersion(version.id));
  }

  Future<void> _addFeedback(
    WorkItemRevisionDetail detail, {
    String? versionId,
  }) async {
    final result = await showDialog<FeedbackDialogResult>(
      context: context,
      builder: (context) => FeedbackDialog(
        versions: detail.versions,
        initialVersionId: versionId,
      ),
    );
    if (result == null) return;
    await _run(() => _repository.createFeedback(
          widget.workItemId,
          versionId: result.versionId,
          body: result.body,
          kind: result.kind,
          timecode: result.timecode,
        ));
  }

  Future<void> _editFeedback(
    WorkItemRevisionDetail detail,
    WorkItemFeedback feedback,
  ) async {
    final linked = detail.versionById(feedback.versionId);
    final result = await showDialog<FeedbackDialogResult>(
      context: context,
      builder: (context) => FeedbackDialog(
        feedback: feedback,
        versions: detail.versions,
        linkedDeletedVersion:
            linked != null && linked.isDeleted ? linked : null,
      ),
    );
    if (result == null) return;
    await _run(() => _repository.updateFeedback(
          feedback.id,
          body: result.body,
          kind: result.kind,
          timecode: result.timecode,
          versionId: result.versionId,
        ));
  }

  Future<void> _deleteFeedback(WorkItemFeedback feedback) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(l10n.deleteFeedbackConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(() => _repository.softDeleteFeedback(feedback.id));
  }

  String _versionLabelFor(WorkItemRevisionDetail detail, String? versionId) {
    final l10n = context.l10n;
    final version = detail.versionById(versionId);
    if (version == null) return l10n.feedbackGeneral;
    return version.isDeleted
        ? l10n.deletedVersionLabel(version.label)
        : version.label;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: _isSaving
            ? const PreferredSize(
                preferredSize: Size.fromHeight(2),
                child: LinearProgressIndicator(minHeight: 2),
              )
            : null,
      ),
      body: FutureBuilder<WorkItemRevisionDetail?>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: FilledButton.tonalIcon(
                onPressed: _reload,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.retry),
              ),
            );
          }
          final detail = snapshot.data;
          if (detail == null) {
            return Center(child: Text(context.l10n.workItemNotFound));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= _wideLayoutBreakpoint) {
                return _buildWide(detail);
              }
              return _buildNarrow(detail);
            },
          );
        },
      ),
    );
  }

  /// Wide window: revisions on the left, history in a fixed-width column.
  Widget _buildWide(WorkItemRevisionDetail detail) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: _revisionSections(detail),
          ),
        ),
        VerticalDivider(
          width: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        SizedBox(
          width: 360,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              WorkItemHistoryList(events: buildWorkItemHistory(detail)),
            ],
          ),
        ),
      ],
    );
  }

  /// Narrow window: two tabs.
  Widget _buildNarrow(WorkItemRevisionDetail detail) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: l10n.revisions),
              Tab(text: l10n.revisionHistory),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: _revisionSections(detail),
                ),
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    WorkItemHistoryList(events: buildWorkItemHistory(detail)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _revisionSections(WorkItemRevisionDetail detail) {
    final l10n = context.l10n;
    final versions = detail.versions;
    final latestId = detail.latestVersion?.id;
    return [
      _RevisionHeader(
        detail: detail,
        onNewVersion: _isSaving ? null : () => _createVersion(detail),
        onAddFeedback: _isSaving
            ? null
            : () => _addFeedback(detail, versionId: detail.latestVersion?.id),
      ),
      const SizedBox(height: 28),
      ..._feedbackSection(detail),
      const SizedBox(height: 28),
      Text(l10n.versions, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      if (versions.isEmpty)
        Text(l10n.deliverableNoVersions)
      else
        for (final version in versions) ...[
          VersionCard(
            version: version,
            isLatest: version.id == latestId,
            onStatusChanged: (status) =>
                _run(() => _repository.setVersionStatus(version.id, status)),
            onEdit: () => _editVersion(version),
            onDelete: () => _deleteVersion(version),
            feedbackSummary: _feedbackCountsFor(detail, version.id),
            onAddFeedback: _isSaving
                ? null
                : () => _addFeedback(detail, versionId: version.id),
          ),
          const SizedBox(height: 8),
        ],
    ];
  }

  String? _feedbackCountsFor(WorkItemRevisionDetail detail, String versionId) {
    final linked =
        detail.feedback.where((item) => item.versionId == versionId).toList();
    if (linked.isEmpty) return null;
    final open = linked.where((item) => item.isOpen).length;
    return context.l10n.feedbackCounts(open, linked.length);
  }

  /// Open feedback by default; "All" also shows closed items.
  List<Widget> _feedbackSection(WorkItemRevisionDetail detail) {
    final l10n = context.l10n;
    final visible = _showAllFeedback
        ? detail.feedback
        : detail.feedback.where((item) => item.isOpen).toList();
    return [
      Wrap(
        spacing: 16,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Text(l10n.feedback, style: Theme.of(context).textTheme.titleLarge),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: false, label: Text(l10n.feedbackStatusOpen)),
              ButtonSegment(value: true, label: Text(l10n.all)),
            ],
            selected: {_showAllFeedback},
            onSelectionChanged: (selection) =>
                setState(() => _showAllFeedback = selection.single),
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (visible.isEmpty)
        Text(_showAllFeedback ? l10n.noFeedback : l10n.noOpenFeedback)
      else
        for (final feedback in visible) ...[
          FeedbackTile(
            key: ValueKey('feedback-${feedback.id}'),
            feedback: feedback,
            versionLabel: _versionLabelFor(detail, feedback.versionId),
            onStatusChanged: (status) =>
                _run(() => _repository.setFeedbackStatus(feedback.id, status)),
            onEdit: () => _editFeedback(detail, feedback),
            onDelete: () => _deleteFeedback(feedback),
          ),
          const SizedBox(height: 8),
        ],
    ];
  }
}

class _RevisionHeader extends StatelessWidget {
  const _RevisionHeader({
    required this.detail,
    required this.onNewVersion,
    required this.onAddFeedback,
  });

  final WorkItemRevisionDetail detail;
  final VoidCallback? onNewVersion;
  final VoidCallback? onAddFeedback;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final state = detail.state;
    final stateColor = deliverableStateColor(colors, state);
    final isClosed = detail.periodStatus == PaymentPeriodStatus.closed;
    final latest = detail.latestVersion;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(detail.clientName, style: theme.textTheme.labelLarge),
                if (isClosed)
                  Chip(
                    avatar: const Icon(Icons.lock_outline, size: 16),
                    label: Text(l10n.closedPeriod),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(deliverableStateIcon(state), color: stateColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    [
                      if (latest != null) latest.label,
                      deliverableStateLabel(l10n, state),
                    ].join(' · '),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: stateColor),
                  ),
                ),
              ],
            ),
            if (detail.openRevisionCount > 0 ||
                detail.openNewScopeCount > 0) ...[
              const SizedBox(height: 6),
              Text(
                [
                  if (detail.openRevisionCount > 0)
                    l10n.openRevisionCount(detail.openRevisionCount),
                  if (detail.openNewScopeCount > 0)
                    l10n.openNewScopeCount(detail.openNewScopeCount),
                ].join(' · '),
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 8),
            Text(l10n.revisionFinancialNote, style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: onNewVersion,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.newVersion),
                ),
                FilledButton.tonalIcon(
                  onPressed: onAddFeedback,
                  icon: const Icon(Icons.add_comment_outlined),
                  label: Text(l10n.addFeedback),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
