import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/payment_allocation.dart';
import 'package:flowledger/models/payment_period.dart';
import 'package:flowledger/models/period_detail.dart';
import 'package:flowledger/models/work_item.dart';
import 'package:flowledger/repositories/payment_period_repository.dart';
import 'package:flowledger/repositories/payment_repository.dart';
import 'package:flowledger/screens/client_detail_screen.dart';
import 'package:flowledger/screens/work_item_revisions_screen.dart';
import 'package:flowledger/widgets/draft_share_field.dart';
import 'package:flutter/material.dart';

class PeriodDetailScreen extends StatefulWidget {
  const PeriodDetailScreen({super.key, required this.periodId});

  final String periodId;

  @override
  State<PeriodDetailScreen> createState() => _PeriodDetailScreenState();
}

class _PeriodDetailScreenState extends State<PeriodDetailScreen> {
  final _periodRepository = PaymentPeriodRepository();
  final _paymentRepository = PaymentRepository();
  late Future<(PeriodDetail?, PeriodPaidWork)> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _load();
  }

  Future<(PeriodDetail?, PeriodPaidWork)> _load() async {
    final detail = await _periodRepository.getPeriodDetail(widget.periodId);
    // Paid marks are extra information; show the period even if they fail.
    final paidWork = await _paymentRepository
        .getPaidWorkForPeriod(widget.periodId)
        .catchError((Object _) => PeriodPaidWork.empty);
    return (detail, paidWork);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.periodReviewTitle)),
      body: FutureBuilder<(PeriodDetail?, PeriodPaidWork)>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final detail = snapshot.data?.$1;
          if (snapshot.hasError || detail == null) {
            return Center(child: Text(context.l10n.periodDetailsLoadFailed));
          }
          return _PeriodDetailBody(
            detail: detail,
            paidWork: snapshot.requireData.$2,
          );
        },
      ),
    );
  }
}

class _PeriodDetailBody extends StatelessWidget {
  const _PeriodDetailBody({required this.detail, required this.paidWork});

  final PeriodDetail detail;
  final PeriodPaidWork paidWork;

  @override
  Widget build(BuildContext context) {
    final summary = detail.summary;
    final period = summary.period;
    final isOpen = period.status == PaymentPeriodStatus.open;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(summary.clientName,
                style: Theme.of(context).textTheme.headlineSmall),
            Chip(
              avatar: Icon(
                  isOpen ? Icons.radio_button_checked : Icons.lock_outline,
                  size: 18),
              label: Text(
                  isOpen ? context.l10n.openPeriodChip : context.l10n.readOnly),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${formatDate(period.startDate)} — ${period.endDate == null ? context.l10n.periodOngoing : formatDate(period.endDate!)}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 40,
              runSpacing: 16,
              children: [
                _Metric(
                    label: context.l10n.totalWorkAmount,
                    value: context.money(summary.totalWorkAmount)),
                _Metric(
                    label: context.l10n.paidAmount,
                    value: context.money(summary.paymentAmount)),
                _Metric(
                    label: context.l10n.remainingAmountLabel,
                    value: context.money(summary.remainingAmount)),
                _Metric(
                    label: context.l10n.workItemCountTitle,
                    value: '${summary.workItemCount}'),
              ],
            ),
          ),
        ),
        if (isOpen) ...[
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ClientDetailScreen(
                  clientId: period.clientId,
                  clientName: summary.clientName,
                ),
              ),
            ),
            icon: const Icon(Icons.open_in_new),
            label: Text(context.l10n.goToClientDetail),
          ),
        ],
        const SizedBox(height: 32),
        Text(context.l10n.periodCategoriesTitle,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (detail.categories.isEmpty)
          Text(context.l10n.noCategorySnapshot)
        else
          for (final category in detail.categories)
            _ReadOnlyItem(
              icon: Icons.category_outlined,
              title: category.name,
              trailing: context.money(category.priceSnapshot),
            ),
        const SizedBox(height: 28),
        Text(context.l10n.worksTitle,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (detail.workItems.isEmpty)
          Text(context.l10n.noWorkInPeriod)
        else
          for (final workItem in detail.workItems)
            _ReadOnlyItem(
              icon: Icons.task_alt_outlined,
              title: workItem.title,
              subtitle: _withNote(
                '${formatDate(workItem.completedAt ?? workItem.createdAt)} · ${context.l10n.quantityWithUnit(context.number(workItem.quantity))}'
                '${_shareSuffix(context, workItem)}'
                '${_paidSuffix(context, paidWork.byWorkItem[workItem.id])}',
                workItem.notes,
              ),
              trailing: context.money(workItem.totalPrice),
              onOpenRevisions: () => WorkItemRevisionsScreen.open(
                context,
                workItemId: workItem.id,
                title: workItem.title,
              ),
            ),
        const SizedBox(height: 28),
        Text(context.l10n.paymentRecordTitle,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        if (detail.payments.isEmpty)
          Text(context.l10n.noPaymentsInPeriod)
        else
          for (final payment in detail.payments)
            _ReadOnlyItem(
              icon: Icons.payments_outlined,
              title: context.money(payment.amount),
              subtitle: _withNote(
                _withNote(
                  formatDate(payment.paidAt),
                  _coveredWork(context, paidWork.titlesForPayment(payment.id)),
                ),
                payment.note,
              ),
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

class _ReadOnlyItem extends StatelessWidget {
  const _ReadOnlyItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onOpenRevisions,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailing;

  /// Work rows open the revisions screen; amounts stay read-only.
  final VoidCallback? onOpenRevisions;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: onOpenRevisions == null
            ? (trailing == null ? null : Text(trailing!))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (trailing != null) Text(trailing!),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: context.l10n.revisions,
                    child: const Icon(Icons.layers_outlined),
                  ),
                ],
              ),
        onTap: onOpenRevisions,
      ),
    );
  }
}

String _withNote(String base, String? note) =>
    note == null || note.isEmpty ? base : '$base\n$note';

String _paidSuffix(BuildContext context, PaidWorkItem? paid) => paid == null
    ? ''
    : ' · ${context.l10n.workItemPaidOn(formatDate(paid.paidAt))}';

String? _coveredWork(BuildContext context, List<String> titles) =>
    titles.isEmpty ? null : context.l10n.paymentCoversWork(titles.join(', '));

String _shareSuffix(BuildContext context, WorkItem workItem) {
  final label = workItemShareLabel(context, workItem);
  return label == null ? '' : ' · $label';
}
