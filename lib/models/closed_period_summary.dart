import 'package:flowledger/models/payment_period.dart';

/// List summary of a closed period.
class ClosedPeriodSummary {
  const ClosedPeriodSummary({
    required this.period,
    required this.totalWorkAmount,
    required this.paymentAmount,
    required this.workItemCount,
  });

  final PaymentPeriod period;
  final double totalWorkAmount;
  final double paymentAmount;
  final int workItemCount;

  double get remainingAmount => totalWorkAmount - paymentAmount;
}
