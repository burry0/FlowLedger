import 'package:flowledger/models/payment.dart';
import 'package:flowledger/models/period_category.dart';
import 'package:flowledger/models/period_with_totals.dart';
import 'package:flowledger/models/work_item.dart';

/// Everything shown on the period detail page.
class PeriodDetail {
  const PeriodDetail({
    required this.summary,
    required this.categories,
    required this.workItems,
    required this.payments,
  });

  final PeriodWithTotals summary;
  final List<PeriodCategory> categories;
  final List<WorkItem> workItems;
  final List<Payment> payments;
}
