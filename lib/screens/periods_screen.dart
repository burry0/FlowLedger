import 'package:flowledger/core/app_refresh_notifier.dart';
import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/client.dart';
import 'package:flowledger/models/payment_period.dart';
import 'package:flowledger/models/period_with_totals.dart';
import 'package:flowledger/repositories/client_repository.dart';
import 'package:flowledger/repositories/payment_period_repository.dart';
import 'package:flowledger/screens/period_detail_screen.dart';
import 'package:flutter/material.dart';

class PeriodsScreen extends StatefulWidget {
  const PeriodsScreen({super.key});

  @override
  State<PeriodsScreen> createState() => _PeriodsScreenState();
}

class _PeriodsScreenState extends State<PeriodsScreen> {
  final _clientRepository = ClientRepository();
  final _periodRepository = PaymentPeriodRepository();
  late Future<List<Client>> _clientsFuture;
  late Future<List<PeriodWithTotals>> _periodsFuture;
  String? _clientId;

  @override
  void initState() {
    super.initState();
    _clientsFuture = _clientRepository.getClients();
    _periodsFuture = _loadPeriods();
    AppRefreshNotifier.revision.addListener(_handleGlobalRefresh);
  }

  @override
  void dispose() {
    AppRefreshNotifier.revision.removeListener(_handleGlobalRefresh);
    super.dispose();
  }

  void _handleGlobalRefresh() {
    if (mounted) _reloadPeriods();
  }

  Future<List<PeriodWithTotals>> _loadPeriods() => _clientId == null
      ? _periodRepository.getAllPeriodsWithTotals()
      : _periodRepository.getPeriodsForClientWithTotals(_clientId!);

  void _selectClient(String? clientId) {
    setState(() {
      _clientId = clientId;
      _periodsFuture = _loadPeriods();
    });
  }

  void _reloadPeriods() => setState(() {
        _clientsFuture = _clientRepository.getClients();
        _periodsFuture = _loadPeriods();
      });

  Future<void> _refreshPeriods() async {
    final clientsFuture = _clientRepository.getClients();
    final periodsFuture = _loadPeriods();
    setState(() {
      _clientsFuture = clientsFuture;
      _periodsFuture = periodsFuture;
    });
    await Future.wait([clientsFuture, periodsFuture]);
  }

  Future<void> _confirmDeletePeriod(PeriodWithTotals summary) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deletePeriodTitle),
        content: Text(context.l10n.deletePeriodMessage),
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
      await _periodRepository.softDeletePaymentPeriod(summary.period.id);
      if (mounted) {
        await _refreshPeriods();
        AppRefreshNotifier.notifyChanged();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.periodDeleteFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 320,
              child: FutureBuilder<List<Client>>(
                future: _clientsFuture,
                builder: (context, snapshot) => DropdownButtonFormField<String>(
                  initialValue: _clientId,
                  decoration: InputDecoration(labelText: context.l10n.client),
                  items: [
                    DropdownMenuItem(
                        value: null, child: Text(context.l10n.allClients)),
                    for (final client in snapshot.data ?? const <Client>[])
                      DropdownMenuItem(
                          value: client.id, child: Text(client.name)),
                  ],
                  onChanged: _selectClient,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: FutureBuilder<List<PeriodWithTotals>>(
            future: _periodsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: FilledButton.tonalIcon(
                    onPressed: _reloadPeriods,
                    icon: const Icon(Icons.refresh),
                    label: Text(context.l10n.retry),
                  ),
                );
              }
              final periods = snapshot.requireData;
              if (periods.isEmpty) {
                return Center(child: Text(context.l10n.noPeriods));
              }
              return ListView.separated(
                itemCount: periods.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) => _PeriodCard(
                  summary: periods[index],
                  onDelete: () => _confirmDeletePeriod(periods[index]),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PeriodDetailScreen(
                            periodId: periods[index].period.id),
                      ),
                    );
                    if (mounted) {
                      await _refreshPeriods();
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard(
      {required this.summary, required this.onTap, required this.onDelete});

  final PeriodWithTotals summary;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final period = summary.period;
    final isOpen = period.status == PaymentPeriodStatus.open;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(summary.clientName,
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  Chip(
                    avatar: Icon(
                        isOpen
                            ? Icons.radio_button_checked
                            : Icons.lock_outline,
                        size: 16),
                    label: Text(isOpen
                        ? context.l10n.activePeriod
                        : context.l10n.closedPeriod),
                  ),
                  IconButton(
                    tooltip: context.l10n.delete,
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${formatDate(period.startDate)} — ${period.endDate == null ? context.l10n.periodOngoing : formatDate(period.endDate!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 36,
                runSpacing: 12,
                children: [
                  _PeriodMetric(
                      label: context.l10n.totalWork,
                      value: context.money(summary.totalWorkAmount)),
                  _PeriodMetric(
                      label: context.l10n.paidAmount,
                      value: context.money(summary.paymentAmount)),
                  _PeriodMetric(
                      label: context.l10n.remainingAmountLabel,
                      value: context.money(summary.remainingAmount)),
                  _PeriodMetric(
                      label: context.l10n.workItemCountTitle,
                      value: '${summary.workItemCount}'),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.visibility_outlined),
                  label: Text(context.l10n.view),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodMetric extends StatelessWidget {
  const _PeriodMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
