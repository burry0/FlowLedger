import 'package:flowledger/models/payment_period.dart';

/// A period with its client and totals, for the periods list.
class PeriodWithTotals {
  const PeriodWithTotals({
    required this.period,
    required this.clientName,
    required this.totalWorkAmount,
    required this.paymentAmount,
    required this.workItemCount,
  });

  final PaymentPeriod period;
  final String clientName;
  final double totalWorkAmount;
  final double paymentAmount;
  final int workItemCount;

  double get remainingAmount => totalWorkAmount - paymentAmount;
}
