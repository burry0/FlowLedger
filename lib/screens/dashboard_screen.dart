import 'package:flowledger/core/app_refresh_notifier.dart';
import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/client_open_balance.dart';
import 'package:flowledger/repositories/dashboard_repository.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dashboardRepository = DashboardRepository();
  late Future<_DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
    AppRefreshNotifier.revision.addListener(_handleGlobalRefresh);
  }

  @override
  void dispose() {
    AppRefreshNotifier.revision.removeListener(_handleGlobalRefresh);
    super.dispose();
  }

  void _handleGlobalRefresh() {
    if (mounted) _reloadDashboard();
  }

  Future<_DashboardData> _loadDashboard() async {
    final now = DateTime.now();
    final totalUnpaid =
        await _dashboardRepository.getTotalUnpaidAcrossOpenPeriods();
    final activeClientCount = await _dashboardRepository.getActiveClientCount();
    final completedWorkItemCount =
        await _dashboardRepository.getCompletedWorkItemCountForMonth(
      now.year,
      now.month,
    );
    final paidTotal =
        await _dashboardRepository.getPaidTotalForMonth(now.year, now.month);
    final clientBalances =
        await _dashboardRepository.getClientsWithOpenBalances();
    return _DashboardData(
      totalUnpaid: totalUnpaid,
      activeClientCount: activeClientCount,
      completedWorkItemCount: completedWorkItemCount,
      paidTotal: paidTotal,
      clientBalances: clientBalances,
    );
  }

  void _reloadDashboard() {
    setState(() {
      _dashboardFuture = _loadDashboard();
    });
  }

  Future<void> _refreshDashboard() async {
    final future = _loadDashboard();
    setState(() {
      _dashboardFuture = future;
    });
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DashboardData>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: FilledButton.tonalIcon(
              onPressed: _reloadDashboard,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.retry),
            ),
          );
        }

        final dashboard = snapshot.requireData;
        return RefreshIndicator(
          onRefresh: _refreshDashboard,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _DashboardCard(
                    label: context.l10n.totalOpenReceivable,
                    value: context.money(dashboard.totalUnpaid),
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  _DashboardCard(
                    label: context.l10n.activeClients,
                    value: '${dashboard.activeClientCount}',
                    icon: Icons.people_outline,
                  ),
                  _DashboardCard(
                    label: context.l10n.workCompletedThisMonth,
                    value: '${dashboard.completedWorkItemCount}',
                    icon: Icons.task_alt_outlined,
                  ),
                  _DashboardCard(
                    label: context.l10n.paymentsReceivedThisMonth,
                    value: context.money(dashboard.paidTotal),
                    icon: Icons.payments_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(context.l10n.clientsWithBalances,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (dashboard.clientBalances.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(context.l10n.noClientBalances),
                )
              else
                for (final client in dashboard.clientBalances) ...[
                  _ClientBalanceCard(balance: client),
                  const SizedBox(height: 8),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _DashboardCard extends StatefulWidget {
  const _DashboardCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 220,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _hovered
                ? colors.surfaceContainerHigh
                : colors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(widget.icon, color: colors.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(widget.value, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientBalanceCard extends StatelessWidget {
  const _ClientBalanceCard({required this.balance});

  final ClientOpenBalance balance;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person_outline),
        title: Text(balance.clientName),
        subtitle: Text(
            '${balance.workItemCount} ${context.l10n.workItems.toLowerCase()}'),
        trailing: Text(
          context.money(balance.openPeriodTotal),
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }
}

class _DashboardData {
  const _DashboardData({
    required this.totalUnpaid,
    required this.activeClientCount,
    required this.completedWorkItemCount,
    required this.paidTotal,
    required this.clientBalances,
  });

  final double totalUnpaid;
  final int activeClientCount;
  final int completedWorkItemCount;
  final double paidTotal;
  final List<ClientOpenBalance> clientBalances;
}
