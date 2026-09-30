import 'package:flowledger/core/app_refresh_notifier.dart';
import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/client_default_category.dart';
import 'package:flowledger/models/closed_period_summary.dart';
import 'package:flowledger/models/payment.dart';
import 'package:flowledger/models/period_category.dart';
import 'package:flowledger/models/work_item.dart';
import 'package:flowledger/models/work_item_revision_summary.dart';
import 'package:flowledger/models/work_item_step.dart';
import 'package:flowledger/repositories/client_default_category_repository.dart';
import 'package:flowledger/repositories/payment_period_repository.dart';
import 'package:flowledger/repositories/payment_repository.dart';
import 'package:flowledger/repositories/revision_repository.dart';
import 'package:flowledger/repositories/work_item_repository.dart';
import 'package:flowledger/screens/payment_dialog.dart';
import 'package:flowledger/screens/period_detail_screen.dart';
import 'package:flowledger/screens/work_item_revisions_screen.dart';
import 'package:flowledger/services/active_period_export_service.dart';
import 'package:flowledger/widgets/client/default_category_widgets.dart';
import 'package:flowledger/widgets/client/period_history_tiles.dart';
import 'package:flowledger/widgets/custom_work_item_dialog.dart';
import 'package:flowledger/widgets/edit_work_item_dialog.dart';
import 'package:flowledger/widgets/period_summary_strip.dart';
import 'package:flowledger/widgets/work_item_tile.dart';
import 'package:flutter/material.dart';

class ClientDetailScreen extends StatefulWidget {
  const ClientDetailScreen({
    super.key,
    required this.clientId,
    required this.clientName,
  });

  final String clientId;
  final String clientName;

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  final _categoryRepository = ClientDefaultCategoryRepository();
  final _paymentPeriodRepository = PaymentPeriodRepository();
  final _paymentRepository = PaymentRepository();
  final _workItemRepository = WorkItemRepository();
  final _revisionRepository = RevisionRepository();
  final _exportService = const ActivePeriodExportService();
  late Future<List<ClientDefaultCategory>> _categoriesFuture;
  late Future<List<PeriodCategory>> _periodCategoriesFuture;
  late Future<_OpenPeriodWorkData> _openPeriodWorkFuture;
  late Future<List<ClosedPeriodSummary>> _closedPeriodsFuture;
  final Set<String> _addingCategoryIds = {};
  var _isRecordingPayment = false;
  ActivePeriodExportFormat? _exportingFormat;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _loadCategories();
    _periodCategoriesFuture = _loadPeriodCategories();
    _openPeriodWorkFuture = _loadOpenPeriodWork();
    _closedPeriodsFuture = _loadClosedPeriods();
    AppRefreshNotifier.revision.addListener(_handleGlobalRefresh);
  }

  @override
  void dispose() {
    AppRefreshNotifier.revision.removeListener(_handleGlobalRefresh);
    super.dispose();
  }

  void _handleGlobalRefresh() {
    if (!mounted) return;
    _reloadAllData();
  }

  void _reloadAllData() {
    setState(() {
      _categoriesFuture = _loadCategories();
      _periodCategoriesFuture = _loadPeriodCategories();
      _openPeriodWorkFuture = _loadOpenPeriodWork();
      _closedPeriodsFuture = _loadClosedPeriods();
    });
  }

  Future<List<ClientDefaultCategory>> _loadCategories() {
    return _categoryRepository.getDefaultCategoriesForClient(widget.clientId);
  }

  Future<List<PeriodCategory>> _loadPeriodCategories() {
    return _paymentPeriodRepository
        .getOpenPeriodCategoriesForClient(widget.clientId);
  }

  Future<_OpenPeriodWorkData> _loadOpenPeriodWork() async {
    final period =
        await _paymentPeriodRepository.ensurePeriodCategoriesForOpenPeriod(
      widget.clientId,
    );
    final total = await _workItemRepository.getOpenPeriodTotal(widget.clientId);
    final workItems = await _workItemRepository
        .getWorkItemsForClientOpenPeriod(widget.clientId);
    final payments = await _paymentRepository.getPaymentsForPeriod(period.id);
    final paymentTotal =
        payments.fold<double>(0, (sum, payment) => sum + payment.amount);
    // Revision summaries are optional; show the page even if they fail.
    final revisionSummaries = await _revisionRepository
        .getSummaries(workItems.map((workItem) => workItem.id))
        .catchError((Object _) => <String, WorkItemRevisionSummary>{});
    return _OpenPeriodWorkData(
      total: total,
      paymentTotal: paymentTotal,
      payments: payments,
      workItems: workItems,
      startDate: period.startDate,
      revisionSummaries: revisionSummaries,
    );
  }

  Future<List<ClosedPeriodSummary>> _loadClosedPeriods() {
    return _paymentPeriodRepository.getClosedPeriodsWithTotals(widget.clientId);
  }

  void _refreshCategories() {
    setState(() {
      _categoriesFuture = _loadCategories();
    });
  }

  Future<void> _refreshCategoriesAndPeriodButtons() async {
    final categoriesFuture = _loadCategories();
    final periodCategoriesFuture = _loadPeriodCategories();
    setState(() {
      _categoriesFuture = categoriesFuture;
      _periodCategoriesFuture = periodCategoriesFuture;
    });
    await Future.wait([categoriesFuture, periodCategoriesFuture]);
  }

  Future<void> _refreshOpenPeriodWork() async {
    final future = _loadOpenPeriodWork();
    setState(() {
      _openPeriodWorkFuture = future;
    });
    await future;
  }

  Future<void> _refreshAfterPayment() async {
    final openPeriodWorkFuture = _loadOpenPeriodWork();
    final periodCategoriesFuture = _loadPeriodCategories();
    final closedPeriodsFuture = _loadClosedPeriods();
    setState(() {
      _openPeriodWorkFuture = openPeriodWorkFuture;
      _periodCategoriesFuture = periodCategoriesFuture;
      _closedPeriodsFuture = closedPeriodsFuture;
    });
    await Future.wait([
      openPeriodWorkFuture,
      periodCategoriesFuture,
      closedPeriodsFuture,
    ]);
  }

  Future<void> _exportActivePeriod(ActivePeriodExportFormat format) async {
    if (_exportingFormat != null) {
      return;
    }
    setState(() => _exportingFormat = format);
    final strings = context.l10n;
    final formatter = context.formatter;
    try {
      final openPeriod = await _loadOpenPeriodWork();
      final path = await _exportService.save(
        ActivePeriodExportData(
          clientName: widget.clientName,
          startDate: openPeriod.startDate,
          workItems: openPeriod.workItems,
          payments: openPeriod.payments,
          strings: strings,
          formatter: formatter,
        ),
        format,
      );
      if (!mounted || path == null) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.exportSaved(
              format == ActivePeriodExportFormat.txt ? 'TXT' : 'XLSX')),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.exportFailed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _exportingFormat = null);
      }
    }
  }

  Future<void> _showPaymentDialog() async {
    final openPeriod = await _loadOpenPeriodWork();
    if (openPeriod.inProgressCount > 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.completeInProgressBeforeClosing)),
      );
      return;
    }
    final remainingAmount =
        openPeriod.remainingAmount <= 0 ? 0.0 : openPeriod.remainingAmount;
    if (!mounted) {
      return;
    }
    final result = await showDialog<PaymentDialogResult>(
      context: context,
      builder: (context) => PaymentDialog(
        initialAmount: remainingAmount,
        maxAmount: remainingAmount,
        helperText:
            context.l10n.remainingPaymentHelper(context.money(remainingAmount)),
      ),
    );
    if (result == null || !mounted) {
      return;
    }

    setState(() => _isRecordingPayment = true);
    try {
      await _paymentRepository.recordPaymentAndStartNewPeriod(
        widget.clientId,
        result.amount,
        result.paidAt,
        result.note,
      );
      if (mounted) {
        await _refreshAfterPayment();
        if (!mounted) return;
        AppRefreshNotifier.notifyChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.paymentRecordedNewPeriod)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.completeInProgressBeforeClosing)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRecordingPayment = false);
      }
    }
  }

  Future<void> _showPartialPaymentDialog() async {
    final openPeriod = await _loadOpenPeriodWork();
    final remainingAmount = openPeriod.remainingAmount;
    if (!mounted) {
      return;
    }
    if (remainingAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.noRemainingPayment)),
      );
      return;
    }

    final result = await showDialog<PaymentDialogResult>(
      context: context,
      builder: (context) => PaymentDialog(
        initialAmount: 0,
        title: context.l10n.partialPaymentTitle,
        submitLabel: context.l10n.savePartialPayment,
        helperText:
            context.l10n.partialPaymentHelper(context.money(remainingAmount)),
        maxAmount: remainingAmount,
        allowZero: false,
      ),
    );
    if (result == null || !mounted) {
      return;
    }

    setState(() => _isRecordingPayment = true);
    try {
      await _paymentRepository.recordPartialPaymentForOpenPeriod(
        widget.clientId,
        result.amount,
        result.paidAt,
        result.note,
      );
      if (mounted) {
        await _refreshAfterPayment();
        if (!mounted) return;
        AppRefreshNotifier.notifyChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.partialPaymentSaved)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.partialPaymentFailed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRecordingPayment = false);
      }
    }
  }

  Future<void> _addWorkItem(PeriodCategory category) async {
    if (_addingCategoryIds.contains(category.id)) {
      return;
    }
    setState(() => _addingCategoryIds.add(category.id));
    try {
      await _workItemRepository.addWorkItemFromPeriodCategory(category.id);
      if (mounted) {
        await _refreshOpenPeriodWork();
        if (!mounted) return;
        AppRefreshNotifier.notifyChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(context.l10n.categoryWorkAdded(category.name))),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.workItemAddFailed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _addingCategoryIds.remove(category.id));
      }
    }
  }

  Future<void> _showCustomWorkItemDialog() async {
    final input = await showDialog<CustomWorkItemInput>(
      context: context,
      builder: (context) => const CustomWorkItemDialog(),
    );
    if (input == null || !mounted) {
      return;
    }
    try {
      await _workItemRepository.addCustomWorkItem(
        widget.clientId,
        input.title,
        input.price,
        input.quantity,
        input.notes,
        createAsCompleted: input.createAsCompleted,
      );
      if (mounted) {
        await _refreshOpenPeriodWork();
        if (!mounted) return;
        AppRefreshNotifier.notifyChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.oneOffWorkAdded)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.workItemAddFailed)),
        );
      }
    }
  }

  Future<void> _showEditWorkItemDialog(WorkItem workItem) async {
    final changes = await showDialog<EditWorkItemResult>(
      context: context,
      builder: (context) => EditWorkItemDialog(workItem: workItem),
    );
    if (changes == null || !mounted) {
      return;
    }

    try {
      await _workItemRepository.updateWorkItem(
        workItem.id,
        title: changes.title,
        quantity: changes.quantity,
        multiplier: changes.multiplier,
        notes: changes.notes,
      );
      if (mounted) {
        await _refreshOpenPeriodWork();
        if (!mounted) return;
        AppRefreshNotifier.notifyChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.workItemUpdated)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.workItemUpdateFailed)),
        );
      }
    }
  }

  Future<void> _setStepDone(WorkItemStep step, bool isDone) async {
    try {
      await _workItemRepository.updateWorkItemStepDone(
        step.id,
        isDone: isDone,
      );
      if (mounted) {
        await _refreshOpenPeriodWork();
        if (!mounted) return;
        AppRefreshNotifier.notifyChanged();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.stageUpdateFailed)),
        );
      }
    }
  }

  Future<void> _markWorkItemCompleted(WorkItem workItem) async {
    final steps = await _workItemRepository.getStepsForWorkItem(workItem.id);
    if (!mounted) return;
    final hasIncompleteSteps = steps.any((step) => !step.isDone);
    if (hasIncompleteSteps) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.notAllStagesCompleted),
          content: Text(context.l10n.confirmCompleteWithOpenStages),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.markAsCompleted),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) {
        return;
      }
    }

    try {
      await _workItemRepository.markWorkItemCompleted(workItem.id);
      if (mounted) {
        await _refreshOpenPeriodWork();
        if (!mounted) return;
        AppRefreshNotifier.notifyChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.completed)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.workCompleteFailed)),
        );
      }
    }
  }

  Future<void> _confirmSoftDeleteWorkItem(WorkItem workItem) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteWorkTitle),
        content: Text(context.l10n.deleteWorkMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await _workItemRepository.softDeleteWorkItem(workItem.id);
      if (mounted) {
        await _refreshOpenPeriodWork();
        if (!mounted) return;
        AppRefreshNotifier.notifyChanged();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.workItemDeleted)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.workItemDeleteFailed)),
        );
      }
    }
  }

  Future<void> _showCategoryDialog([ClientDefaultCategory? category]) async {
    final didSave = await showDialog<bool>(
      context: context,
      builder: (context) => DefaultCategoryDialog(
        clientId: widget.clientId,
        category: category,
        repository: _categoryRepository,
      ),
    );
    if (didSave == true && mounted) {
      await _refreshCategoriesAndPeriodButtons();
      AppRefreshNotifier.notifyChanged();
    }
  }

  Future<void> _confirmSoftDelete(ClientDefaultCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteCategoryTitle),
        content: Text(
          context.l10n.deleteCategoryMessage(category.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await _categoryRepository.softDeleteDefaultCategory(category.id);
      if (mounted) {
        await _refreshCategoriesAndPeriodButtons();
        AppRefreshNotifier.notifyChanged();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.categoryDeleteFailed)),
        );
      }
    }
  }

  Widget _buildPeriodHistory() {
    return FutureBuilder<List<ClosedPeriodSummary>>(
      future: _closedPeriodsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: FilledButton.tonalIcon(
              onPressed: () => setState(() {
                _closedPeriodsFuture = _loadClosedPeriods();
              }),
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retry),
            ),
          );
        }

        final periods = snapshot.requireData;
        if (periods.isEmpty) {
          return Center(child: Text(context.l10n.noClosedPeriods));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: periods.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final summary = periods[index];
            return ClosedPeriodCard(
              summary: summary,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      PeriodDetailScreen(periodId: summary.period.id),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWorkItemRow(
    WorkItem workItem,
    Map<String, WorkItemRevisionSummary> revisionSummaries,
  ) {
    final l10n = context.l10n;
    final isCompleted = workItem.status == WorkItemStatus.completed;
    final statusLabel = isCompleted ? l10n.completed : l10n.inProgress;
    final multiplier = workItem.multiplier == 1
        ? ''
        : ' · ×${context.number(workItem.multiplier)}';
    return WorkItemTile(
      key: ValueKey(workItem.id),
      workItem: workItem,
      repository: _workItemRepository,
      subtitle: '$statusLabel · '
          '${l10n.quantityWithUnit(context.number(workItem.quantity))} · '
          '${context.money(workItem.priceSnapshot)}$multiplier',
      metrics: [
        (label: l10n.status, value: statusLabel),
        (label: l10n.quantity, value: context.number(workItem.quantity)),
        (label: l10n.amount, value: context.money(workItem.totalPrice)),
        if (workItem.completedAt != null)
          (label: l10n.date, value: formatDateTime(workItem.completedAt!)),
      ],
      revisionSummary: revisionSummaries[workItem.id],
      onOpenRevisions: () => WorkItemRevisionsScreen.open(
        context,
        workItemId: workItem.id,
        title: workItem.title,
      ),
      onStepChanged: _setStepDone,
      onEdit: () => _showEditWorkItemDialog(workItem),
      onDelete: () => _confirmSoftDeleteWorkItem(workItem),
      onMarkCompleted: () => _markWorkItemCompleted(workItem),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${context.l10n.clients} / ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(text: widget.clientName),
              ],
            ),
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: context.l10n.activePeriod),
              Tab(text: context.l10n.pastPeriods),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(24),
              children: [
                FutureBuilder<_OpenPeriodWorkData>(
                  future: _openPeriodWorkFuture,
                  builder: (context, snapshot) {
                    final data = snapshot.data;
                    final total = data?.total ?? 0;
                    final paymentTotal = data?.paymentTotal ?? 0;
                    final remainingAmount = data?.remainingAmount ?? total;
                    final theme = Theme.of(context);
                    return Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(context.l10n.activePeriod,
                                        style: theme.textTheme.titleMedium),
                                    const SizedBox(height: 4),
                                    Text(
                                      data != null
                                          ? context.l10n.periodStartedSummary(
                                              formatDateTime(data.startDate),
                                              context.money(total),
                                              context.money(paymentTotal),
                                            )
                                          : context.l10n.periodInfoLoading,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: !snapshot.hasData ||
                                              _exportingFormat != null
                                          ? null
                                          : () => _exportActivePeriod(
                                                ActivePeriodExportFormat.txt,
                                              ),
                                      icon: _exportingFormat ==
                                              ActivePeriodExportFormat.txt
                                          ? const SizedBox.square(
                                              dimension: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.description_outlined,
                                            ),
                                      label: Text(context.l10n.exportTxt),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: !snapshot.hasData ||
                                              _exportingFormat != null
                                          ? null
                                          : () => _exportActivePeriod(
                                                ActivePeriodExportFormat.xlsx,
                                              ),
                                      icon: _exportingFormat ==
                                              ActivePeriodExportFormat.xlsx
                                          ? const SizedBox.square(
                                              dimension: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.table_view_outlined,
                                            ),
                                      label: Text(context.l10n.exportXlsx),
                                    ),
                                    FilledButton.tonalIcon(
                                      onPressed: _isRecordingPayment ||
                                              remainingAmount <= 0
                                          ? null
                                          : _showPartialPaymentDialog,
                                      icon: const Icon(Icons.price_check),
                                      label: Text(
                                          context.l10n.partialPaymentButton),
                                    ),
                                    FilledButton.icon(
                                      onPressed: _isRecordingPayment
                                          ? null
                                          : _showPaymentDialog,
                                      icon: const Icon(Icons.payments_outlined),
                                      label: Text(context.l10n.recordPayment),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Divider(
                                height: 1,
                                color: theme.colorScheme.outlineVariant),
                            const SizedBox(height: 20),
                            PeriodSummaryStrip(
                              metrics: [
                                PeriodSummaryMetric(
                                  label: context.l10n.receivable,
                                  value: context.money(remainingAmount),
                                  emphasized: true,
                                ),
                                PeriodSummaryMetric(
                                  label: context.l10n.inProgress,
                                  value:
                                      '${context.l10n.workItemCountLabel(data?.inProgressCount ?? 0)} · '
                                      '${context.money(data?.inProgressTotal ?? 0)}',
                                ),
                                PeriodSummaryMetric(
                                  label: context.l10n.openRevisions,
                                  value: '${data?.openRevisionCount ?? 0}',
                                ),
                                PeriodSummaryMetric(
                                  label: context.l10n.awaitingFeedback,
                                  value: '${data?.awaitingFeedbackCount ?? 0}',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(context.l10n.quickAddWork,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: _showCustomWorkItemDialog,
                  icon: const Icon(Icons.add_circle_outline),
                  label: Text('+ ${context.l10n.oneOffWork}'),
                ),
                const SizedBox(height: 16),
                Text(context.l10n.periodCategories,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  context.l10n.pricesFixedNote,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<PeriodCategory>>(
                  future: _periodCategoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text(
                        context.l10n.periodCategoriesLoadFailed,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      );
                    }

                    final categories = snapshot.requireData;
                    if (categories.isEmpty) {
                      return Text(context.l10n.noCategoriesInPeriod);
                    }
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final category in categories)
                          SizedBox(
                            width: 240,
                            height: 84,
                            child: OutlinedButton(
                              onPressed:
                                  _addingCategoryIds.contains(category.id)
                                      ? null
                                      : () => _addWorkItem(category),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(context.money(category.priceSnapshot)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(context.l10n.workItems,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                FutureBuilder<_OpenPeriodWorkData>(
                  future: _openPeriodWorkFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text(
                        context.l10n.workItemsLoadFailed,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      );
                    }

                    final workItems = snapshot.requireData.workItems;
                    final revisionSummaries =
                        snapshot.requireData.revisionSummaries;
                    if (workItems.isEmpty) {
                      return Text(context.l10n.noWorkItemsInPeriodYet);
                    }
                    return Card(
                      margin: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          for (var index = 0;
                              index < workItems.length;
                              index++) ...[
                            if (index > 0)
                              Divider(
                                height: 1,
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                              ),
                            _buildWorkItemRow(
                                workItems[index], revisionSummaries),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(context.l10n.thisPeriodPayments,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                FutureBuilder<_OpenPeriodWorkData>(
                  future: _openPeriodWorkFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text(
                        context.l10n.paymentsLoadFailed,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      );
                    }

                    final payments = snapshot.requireData.payments;
                    if (payments.isEmpty) {
                      return Text(context.l10n.noPaymentsInPeriod);
                    }
                    return Column(
                      children: [
                        for (final payment in payments) ...[
                          PaymentHistoryTile(payment: payment),
                          const SizedBox(height: 8),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),
                Text(context.l10n.defaultCategories,
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  context.l10n.defaultCategoriesNote,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.pastPeriodsUnaffected,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: _showCategoryDialog,
                    child: Text('+ ${context.l10n.addCategory}'),
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<ClientDefaultCategory>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: FilledButton.tonalIcon(
                          onPressed: _refreshCategories,
                          icon: const Icon(Icons.refresh),
                          label: Text(context.l10n.retry),
                        ),
                      );
                    }

                    final categories = snapshot.requireData;
                    if (categories.isEmpty) {
                      return const NoDefaultCategories();
                    }
                    return Column(
                      children: [
                        for (final category in categories) ...[
                          DefaultCategoryTile(
                            category: category,
                            onEdit: () => _showCategoryDialog(category),
                            onDelete: () => _confirmSoftDelete(category),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
            _buildPeriodHistory(),
          ],
        ),
      ),
    );
  }
}

class _OpenPeriodWorkData {
  const _OpenPeriodWorkData({
    required this.total,
    required this.paymentTotal,
    required this.payments,
    required this.workItems,
    required this.startDate,
    required this.revisionSummaries,
  });

  final double total;
  final double paymentTotal;
  final List<Payment> payments;
  final List<WorkItem> workItems;
  final DateTime startDate;
  final Map<String, WorkItemRevisionSummary> revisionSummaries;

  double get remainingAmount => total - paymentTotal;

  int get openRevisionCount => revisionSummaries.values
      .fold(0, (sum, summary) => sum + summary.openRevisionCount);

  int get awaitingFeedbackCount => revisionSummaries.values
      .where((summary) => summary.state == DeliverableState.waitingForFeedback)
      .length;

  Iterable<WorkItem> get completedWorkItems =>
      workItems.where((item) => item.status == WorkItemStatus.completed);

  Iterable<WorkItem> get inProgressWorkItems =>
      workItems.where((item) => item.status == WorkItemStatus.inProgress);

  int get completedCount => completedWorkItems.length;

  int get inProgressCount => inProgressWorkItems.length;

  double get inProgressTotal => inProgressWorkItems.fold<double>(
        0,
        (sum, item) => sum + item.totalPrice,
      );

  DateTime? get lastWorkDate {
    if (workItems.isEmpty) {
      return null;
    }
    return workItems
        .map((item) => item.completedAt ?? item.createdAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }
}
