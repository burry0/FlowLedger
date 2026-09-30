import 'package:flowledger/core/app_refresh_notifier.dart';
import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/client.dart';
import 'package:flowledger/models/payment_period.dart';
import 'package:flowledger/models/period_category.dart';
import 'package:flowledger/models/work_item.dart';
import 'package:flowledger/models/work_item_filters.dart';
import 'package:flowledger/models/work_item_revision_summary.dart';
import 'package:flowledger/models/work_item_step.dart';
import 'package:flowledger/models/work_item_with_client.dart';
import 'package:flowledger/repositories/client_repository.dart';
import 'package:flowledger/repositories/payment_period_repository.dart';
import 'package:flowledger/repositories/revision_repository.dart';
import 'package:flowledger/repositories/work_item_repository.dart';
import 'package:flowledger/screens/work_item_revisions_screen.dart';
import 'package:flowledger/widgets/custom_work_item_dialog.dart';
import 'package:flowledger/widgets/work_item_tile.dart';
import 'package:flowledger/widgets/works/quick_add_bar.dart';
import 'package:flowledger/widgets/works/works_filter_panel.dart';
import 'package:flutter/material.dart';

class WorksScreen extends StatefulWidget {
  const WorksScreen({super.key});

  @override
  State<WorksScreen> createState() => _WorksScreenState();
}

class _WorksScreenState extends State<WorksScreen> {
  final _workItemRepository = WorkItemRepository();
  final _clientRepository = ClientRepository();
  final _periodRepository = PaymentPeriodRepository();
  final _revisionRepository = RevisionRepository();
  final _filtersKey = GlobalKey<WorksFilterPanelState>();

  late Future<List<WorkItemWithClient>> _workItemsFuture;
  late Future<Map<String, WorkItemRevisionSummary>> _revisionSummariesFuture;
  late Future<List<Client>> _clientsFuture;
  late Future<List<String>> _categoryNamesFuture;
  Future<List<PeriodCategory>>? _selectedClientCategoriesFuture;
  Client? _selectedClient;
  var _filters = const WorkItemFilters();
  var _isCreatingWork = false;

  @override
  void initState() {
    super.initState();
    _reloadFutures();
    AppRefreshNotifier.revision.addListener(_handleGlobalRefresh);
  }

  @override
  void dispose() {
    AppRefreshNotifier.revision.removeListener(_handleGlobalRefresh);
    super.dispose();
  }

  void _handleGlobalRefresh() {
    if (mounted) {
      _reloadFutures();
    }
  }

  void _reloadFutures() {
    setState(() {
      _workItemsFuture = _workItemRepository.getFilteredWorkItems(_filters);
      _revisionSummariesFuture = _summariesFor(_workItemsFuture);
      _clientsFuture = _clientRepository.getClients();
      _categoryNamesFuture = _workItemRepository.getWorkItemCategoryNames();
      final selectedClient = _selectedClient;
      if (selectedClient != null) {
        _selectedClientCategoriesFuture = _periodRepository
            .getOpenPeriodCategoriesForClient(selectedClient.id);
      }
    });
  }

  Future<void> _refreshData() async {
    final workItemsFuture = _workItemRepository.getFilteredWorkItems(_filters);
    final clientsFuture = _clientRepository.getClients();
    final categoryNamesFuture = _workItemRepository.getWorkItemCategoryNames();
    final selectedClient = _selectedClient;
    final selectedCategoriesFuture = selectedClient == null
        ? null
        : _periodRepository.getOpenPeriodCategoriesForClient(selectedClient.id);

    setState(() {
      _workItemsFuture = workItemsFuture;
      _revisionSummariesFuture = _summariesFor(workItemsFuture);
      _clientsFuture = clientsFuture;
      _categoryNamesFuture = categoryNamesFuture;
      _selectedClientCategoriesFuture = selectedCategoriesFuture;
    });

    await Future.wait([
      workItemsFuture,
      clientsFuture,
      categoryNamesFuture,
      if (selectedCategoriesFuture != null) selectedCategoriesFuture,
    ]);
  }

  void _setFilters(WorkItemFilters filters) {
    setState(() {
      _filters = filters;
      _workItemsFuture = _workItemRepository.getFilteredWorkItems(filters);
      _revisionSummariesFuture = _summariesFor(_workItemsFuture);
    });
  }

  /// One batched summary query for every item in the list.
  Future<Map<String, WorkItemRevisionSummary>> _summariesFor(
    Future<List<WorkItemWithClient>> workItemsFuture,
  ) async {
    final items = await workItemsFuture;
    return _revisionRepository
        .getSummaries(items.map((item) => item.workItem.id));
  }

  void _clearFilters() => _filtersKey.currentState?.clear();

  Future<void> _selectClient() async {
    final clients = await _clientsFuture;
    if (!mounted) {
      return;
    }
    final selected = await showDialog<Client>(
      context: context,
      builder: (context) => _ClientSelectorDialog(clients: clients),
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      _selectedClient = selected;
      _selectedClientCategoriesFuture =
          _periodRepository.getOpenPeriodCategoriesForClient(selected.id);
    });
  }

  Future<void> _addWorkFromCategory(PeriodCategory category) async {
    if (_isCreatingWork) {
      return;
    }
    setState(() => _isCreatingWork = true);
    try {
      await _workItemRepository.addWorkItemFromPeriodCategory(category.id);
      if (!mounted) {
        return;
      }
      await _refreshData();
      if (!mounted) {
        return;
      }
      AppRefreshNotifier.notifyChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.workItemAdded)),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.workItemAddFailed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingWork = false);
      }
    }
  }

  Future<void> _showOneOffForSelectedClient() async {
    final client = _selectedClient;
    if (client == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.clientRequired)),
      );
      return;
    }
    await _showOneOffForClient(client);
  }

  Future<void> _showGlobalOneOffDialog() async {
    final clients = await _clientsFuture;
    if (!mounted) {
      return;
    }
    final selected = await showDialog<Client>(
      context: context,
      builder: (context) => _ClientSelectorDialog(clients: clients),
    );
    if (selected == null || !mounted) {
      return;
    }
    await _showOneOffForClient(selected);
  }

  Future<void> _showOneOffForClient(Client client) async {
    final input = await showDialog<CustomWorkItemInput>(
      context: context,
      builder: (context) => const CustomWorkItemDialog(),
    );
    if (input == null || !mounted) {
      return;
    }

    try {
      await _workItemRepository.addCustomWorkItem(
        client.id,
        input.title,
        input.price,
        input.quantity,
        input.notes,
        createAsCompleted: input.createAsCompleted,
      );
      if (!mounted) {
        return;
      }
      if (_selectedClient?.id == client.id) {
        _selectedClient = client;
      }
      await _refreshData();
      if (!mounted) {
        return;
      }
      AppRefreshNotifier.notifyChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.workItemAdded)),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.workItemAddFailed)),
        );
      }
    }
  }

  Future<void> _confirmDeleteWorkItem(WorkItemWithClient item) async {
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
      await _workItemRepository.softDeleteWorkItem(item.workItem.id);
      if (!mounted) {
        return;
      }
      await _refreshData();
      if (!mounted) {
        return;
      }
      AppRefreshNotifier.notifyChanged();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.workItemDeleteFailed)),
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
      if (!mounted) return;
      await _refreshData();
      if (!mounted) return;
      AppRefreshNotifier.notifyChanged();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.stageUpdateFailed)),
        );
      }
    }
  }

  Future<void> _markWorkItemCompleted(WorkItemWithClient item) async {
    final steps =
        await _workItemRepository.getStepsForWorkItem(item.workItem.id);
    if (!mounted) return;
    if (steps.any((step) => !step.isDone)) {
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
      await _workItemRepository.markWorkItemCompleted(item.workItem.id);
      if (!mounted) return;
      await _refreshData();
      if (!mounted) return;
      AppRefreshNotifier.notifyChanged();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.workCompleteFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: _selectClient,
              icon: const Icon(Icons.person_search_outlined),
              label: Text(context.l10n.selectClient),
            ),
            FilledButton.tonalIcon(
              onPressed: _showGlobalOneOffDialog,
              icon: const Icon(Icons.add_circle_outline),
              label: Text(context.l10n.addOneOffWork),
            ),
            TextButton.icon(
              onPressed: _filters.isEmpty ? null : _clearFilters,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: Text(context.l10n.clearFilters),
            ),
          ],
        ),
        if (_selectedClient != null) ...[
          const SizedBox(height: 16),
          QuickAddBar(
            client: _selectedClient!,
            categoriesFuture: _selectedClientCategoriesFuture!,
            isCreatingWork: _isCreatingWork,
            onCategoryTap: _addWorkFromCategory,
            onOneOffTap: _showOneOffForSelectedClient,
          ),
        ],
        const SizedBox(height: 16),
        FutureBuilder<List<Client>>(
          future: _clientsFuture,
          builder: (context, clientSnapshot) {
            return FutureBuilder<List<String>>(
              future: _categoryNamesFuture,
              builder: (context, categorySnapshot) => WorksFilterPanel(
                key: _filtersKey,
                clients: clientSnapshot.data ?? const [],
                categoryNames: categorySnapshot.data ?? const [],
                onChanged: _setFilters,
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Expanded(
          child: FutureBuilder<List<WorkItemWithClient>>(
            future: _workItemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: FilledButton.tonalIcon(
                    onPressed: _reloadFutures,
                    icon: const Icon(Icons.refresh),
                    label: Text(context.l10n.retry),
                  ),
                );
              }

              final workItems = snapshot.requireData;
              if (workItems.isEmpty) {
                return Center(child: Text(context.l10n.noWorkItems));
              }
              final total = workItems.fold<double>(
                0,
                (sum, item) => item.workItem.status == WorkItemStatus.completed
                    ? sum + item.workItem.totalPrice
                    : sum,
              );
              return FutureBuilder<Map<String, WorkItemRevisionSummary>>(
                future: _revisionSummariesFuture,
                builder: (context, summarySnapshot) {
                  final revisionSummaries = summarySnapshot.data ??
                      const <String, WorkItemRevisionSummary>{};
                  return ListView.separated(
                    itemCount: workItems.length + 1,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _FilteredWorkSummary(
                          total: total,
                          count: workItems.length,
                        );
                      }
                      final item = workItems[index - 1];
                      return Card(
                        key: ValueKey(item.workItem.id),
                        child: _buildWorkItemTile(item, revisionSummaries),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWorkItemTile(
    WorkItemWithClient item,
    Map<String, WorkItemRevisionSummary> revisionSummaries,
  ) {
    final l10n = context.l10n;
    final workItem = item.workItem;
    final categoryName = item.categoryName ?? l10n.oneOffWork;
    final isOpen = item.periodStatus == PaymentPeriodStatus.open;
    final isCompleted = workItem.status == WorkItemStatus.completed;
    return WorkItemTile(
      workItem: workItem,
      repository: _workItemRepository,
      subtitle: '${item.clientName} · $categoryName · '
          '${isCompleted ? l10n.completed : l10n.inProgress}',
      metrics: [
        (label: l10n.client, value: item.clientName),
        (label: l10n.category, value: categoryName),
        (label: l10n.quantity, value: context.number(workItem.quantity)),
        (
          label: l10n.date,
          value: formatDateTime(workItem.completedAt ?? workItem.createdAt),
        ),
      ],
      revisionSummary: revisionSummaries[workItem.id],
      onOpenRevisions: () => WorkItemRevisionsScreen.open(
        context,
        workItemId: workItem.id,
        title: workItem.title,
      ),
      onStepChanged: _setStepDone,
      stepsEditable: isOpen,
      onDelete: isOpen ? () => _confirmDeleteWorkItem(item) : null,
      onMarkCompleted: isOpen ? () => _markWorkItemCompleted(item) : null,
    );
  }
}

class _ClientSelectorDialog extends StatelessWidget {
  const _ClientSelectorDialog({required this.clients});

  final List<Client> clients;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(context.l10n.selectClient),
      children: [
        for (final client in clients)
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(client),
            child: Text(client.name),
          ),
        if (clients.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(context.l10n.noClients),
          ),
      ],
    );
  }
}

class _FilteredWorkSummary extends StatelessWidget {
  const _FilteredWorkSummary({required this.total, required this.count});

  final double total;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Wrap(
          spacing: 48,
          runSpacing: 12,
          children: [
            _FilterMetric(
                label: context.l10n.filteredTotal, value: context.money(total)),
            _FilterMetric(label: context.l10n.workCount, value: '$count'),
          ],
        ),
      ),
    );
  }
}

class _FilterMetric extends StatelessWidget {
  const _FilterMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}
