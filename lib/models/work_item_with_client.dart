import 'package:flowledger/models/payment_period.dart';
import 'package:flowledger/models/work_item.dart';

/// A work item with its client and category, for the works list.
class WorkItemWithClient {
  const WorkItemWithClient({
    required this.workItem,
    required this.clientName,
    required this.periodStatus,
    this.categoryName,
  });

  final WorkItem workItem;
  final String clientName;
  final String? categoryName;
  final PaymentPeriodStatus periodStatus;
}
