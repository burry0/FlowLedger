import 'package:flowledger/core/app_refresh_notifier.dart';
import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/client.dart';
import 'package:flowledger/models/payment.dart';
import 'package:flowledger/repositories/client_repository.dart';
import 'package:flowledger/repositories/payment_repository.dart';
import 'package:flowledger/repositories/work_item_repository.dart';
import 'package:flowledger/screens/client_detail_screen.dart';
import 'package:flowledger/widgets/empty_state.dart';
import 'package:flutter/material.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _clientRepository = ClientRepository();
  final _workItemRepository = WorkItemRepository();
  final _paymentRepository = PaymentRepository();
  late Future<List<_ClientCardData>> _clientsFuture;

  @override
  void initState() {
    super.initState();
    _clientsFuture = _loadClients();
    AppRefreshNotifier.revision.addListener(_handleGlobalRefresh);
  }

  @override
  void dispose() {
    AppRefreshNotifier.revision.removeListener(_handleGlobalRefresh);
    super.dispose();
  }

  void _handleGlobalRefresh() {
    if (mounted) _reloadClients();
  }

  Future<List<_ClientCardData>> _loadClients() async {
    final clients = await _clientRepository.getClients();
    return Future.wait(clients.map(_loadClientCardData));
  }

  Future<_ClientCardData> _loadClientCardData(Client client) async {
    var openPeriod = await _clientRepository.getOpenPeriodForClient(client.id);
    openPeriod ??= await _clientRepository.ensureOpenPeriodForClient(client.id);
    final workItems = await _workItemRepository.getForPeriod(openPeriod.id);
    final payments =
        await _paymentRepository.getPaymentHistoryForClient(client.id);
    final total =
        workItems.fold<double>(0, (sum, item) => sum + item.totalPrice);

    return _ClientCardData(
      client: client,
      total: total,
      workItemCount: workItems.length,
      lastPayment: payments.isEmpty ? null : payments.first,
    );
  }

  void _reloadClients() {
    setState(() {
      _clientsFuture = _loadClients();
    });
  }

  Future<void> _refreshClients() async {
    final future = _loadClients();
    setState(() {
      _clientsFuture = future;
    });
    await future;
  }

  Future<void> _showCreateClientDialog() async {
    final wasCreated = await showDialog<bool>(
      context: context,
      builder: (context) => _CreateClientDialog(repository: _clientRepository),
    );
    if (wasCreated == true && mounted) {
      await _refreshClients();
      AppRefreshNotifier.notifyChanged();
    }
  }

  Future<void> _confirmDeleteClient(Client client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteClientTitle),
        content: Text(context.l10n.deleteClientMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.cancel)),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.delete)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await _clientRepository.softDeleteClient(client.id);
      if (mounted) {
        await _refreshClients();
        AppRefreshNotifier.notifyChanged();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.clientDeleteFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton(
          onPressed: _showCreateClientDialog,
          child: Text('+ ${context.l10n.addClient}'),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: FutureBuilder<List<_ClientCardData>>(
            future: _clientsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: FilledButton.tonalIcon(
                    onPressed: _reloadClients,
                    icon: const Icon(Icons.refresh),
                    label: Text(context.l10n.retry),
                  ),
                );
              }

              final clients = snapshot.requireData;
              if (clients.isEmpty) {
                return EmptyState(
                  icon: Icons.people_outline,
                  title: context.l10n.noClients,
                  description: context.l10n.addFirstClient,
                );
              }

              return ListView.separated(
                itemCount: clients.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final data = clients[index];
                  return _ClientCard(
                    data: data,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ClientDetailScreen(
                          clientId: data.client.id,
                          clientName: data.client.name,
                        ),
                      ),
                    ),
                    onDelete: () => _confirmDeleteClient(data.client),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard(
      {required this.data, required this.onTap, required this.onDelete});

  final _ClientCardData data;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Text(data.client.name,
                          style: Theme.of(context).textTheme.titleLarge)),
                  IconButton(
                    tooltip: context.l10n.delete,
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 32,
                runSpacing: 12,
                children: [
                  _Metric(
                    label: context.l10n.totalOpenReceivable,
                    value: context.money(data.total),
                    color: colorScheme.primary,
                  ),
                  _Metric(
                    label: context.l10n.activePeriod,
                    value:
                        '${data.workItemCount} ${context.l10n.workItems.toLowerCase()}',
                    color: colorScheme.onSurface,
                  ),
                ],
              ),
              if (data.lastPayment != null) ...[
                const SizedBox(height: 16),
                Text(
                  context.l10n
                      .lastPayment(formatDate(data.lastPayment!.paidAt)),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(context.l10n.open),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(
      {required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 2),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: color)),
      ],
    );
  }
}

class _CreateClientDialog extends StatefulWidget {
  const _CreateClientDialog({required this.repository});

  final ClientRepository repository;

  @override
  State<_CreateClientDialog> createState() => _CreateClientDialogState();
}

class _CreateClientDialogState extends State<_CreateClientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  var _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      final notes = _notesController.text.trim();
      await widget.repository.createClient(
        _nameController.text,
        notes.isEmpty ? null : notes,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = context.l10n.clientSaveFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.addClient),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: InputDecoration(labelText: context.l10n.clientName),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  return value == null || value.trim().isEmpty
                      ? context.l10n.clientNameRequired
                      : null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: context.l10n.notes),
                minLines: 2,
                maxLines: 4,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child:
              Text(_isSaving ? '${context.l10n.save}...' : context.l10n.save),
        ),
      ],
    );
  }
}

class _ClientCardData {
  const _ClientCardData({
    required this.client,
    required this.total,
    required this.workItemCount,
    this.lastPayment,
  });

  final Client client;
  final double total;
  final int workItemCount;
  final Payment? lastPayment;
}
