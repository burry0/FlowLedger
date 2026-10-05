import 'package:flowledger/models/model_converters.dart';

/// Marks a work item as paid by a payment. [amount] is the work item total at
/// the time of payment; balances are not calculated from allocations.
class PaymentAllocation {
  const PaymentAllocation({
    required this.id,
    required this.paymentId,
    required this.workItemId,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String paymentId;
  final String workItemId;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  DatabaseRow toMap() => {
        'id': id,
        'payment_id': paymentId,
        'work_item_id': workItemId,
        'amount': amount,
        'created_at': isoDate(createdAt),
        'updated_at': isoDate(updatedAt),
        'deleted_at': deletedAt == null ? null : isoDate(deletedAt!),
      };
}

/// A paid work item with the payment that covers it, for display.
class PaidWorkItem {
  const PaidWorkItem({
    required this.workItemId,
    required this.workItemTitle,
    required this.paymentId,
    required this.paidAt,
  });

  final String workItemId;
  final String workItemTitle;
  final String paymentId;
  final DateTime paidAt;
}

/// Paid work items of one period, looked up by work item or by payment.
class PeriodPaidWork {
  PeriodPaidWork(List<PaidWorkItem> items)
      : byWorkItem = {for (final item in items) item.workItemId: item},
        _items = items;

  static final empty = PeriodPaidWork(const []);

  final Map<String, PaidWorkItem> byWorkItem;
  final List<PaidWorkItem> _items;

  bool isPaid(String workItemId) => byWorkItem.containsKey(workItemId);

  List<String> titlesForPayment(String paymentId) => [
        for (final item in _items)
          if (item.paymentId == paymentId) item.workItemTitle,
      ];
}
