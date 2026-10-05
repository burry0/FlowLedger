import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/models/closed_period_summary.dart';
import 'package:flowledger/models/payment.dart';
import 'package:flutter/material.dart';

class ClosedPeriodCard extends StatelessWidget {
  const ClosedPeriodCard(
      {super.key, required this.summary, required this.onTap});

  final ClosedPeriodSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final period = summary.period;
    final endDate = period.endDate;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.closedPeriodTitle,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                  '${formatDateTime(period.startDate)} — ${endDate == null ? '—' : formatDateTime(endDate)}'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 28,
                runSpacing: 12,
                children: [
                  _ClosedPeriodMetric(
                    label: context.l10n.periodTotal,
                    value: context.money(summary.totalWorkAmount),
                  ),
                  _ClosedPeriodMetric(
                    label: context.l10n.paidAmount,
                    value: context.money(summary.paymentAmount),
                  ),
                  _ClosedPeriodMetric(
                    label: context.l10n.remainingAmountLabel,
                    value: context.money(summary.remainingAmount),
                  ),
                  _ClosedPeriodMetric(
                    label: context.l10n.workItemCountTitle,
                    value: '${summary.workItemCount}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClosedPeriodMetric extends StatelessWidget {
  const _ClosedPeriodMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}

class PaymentHistoryTile extends StatelessWidget {
  const PaymentHistoryTile({
    super.key,
    required this.payment,
    this.coveredWorkTitles = const [],
  });

  final Payment payment;

  /// Titles of the work items this payment was recorded for, if any.
  final List<String> coveredWorkTitles;

  @override
  Widget build(BuildContext context) {
    final note = payment.note;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.payments_outlined),
        title: Text(context.money(payment.amount)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(formatDateTime(payment.paidAt)),
            if (coveredWorkTitles.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                  context.l10n.paymentCoversWork(coveredWorkTitles.join(', '))),
            ],
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(note),
            ],
          ],
        ),
      ),
    );
  }
}
