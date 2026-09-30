enum WorkTypeFilter { all, categorized, custom }

enum PeriodStatusFilter { all, open, closed }

enum WorkStatusFilter { all, inProgress, completed }

/// Filters for the works list. Every field is optional; the ones that are set
/// are combined with AND.
class WorkItemFilters {
  const WorkItemFilters({
    this.clientId,
    this.categoryName,
    this.startDate,
    this.endDate,
    this.minimumAmount,
    this.maximumAmount,
    this.minimumQuantity,
    this.maximumQuantity,
    this.workType = WorkTypeFilter.all,
    this.periodStatus = PeriodStatusFilter.all,
    this.status = WorkStatusFilter.all,
  });

  static const customCategoryValue = '__custom__';

  final String? clientId;
  final String? categoryName;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minimumAmount;
  final double? maximumAmount;
  final double? minimumQuantity;
  final double? maximumQuantity;
  final WorkTypeFilter workType;
  final PeriodStatusFilter periodStatus;
  final WorkStatusFilter status;

  bool get isEmpty =>
      clientId == null &&
      categoryName == null &&
      startDate == null &&
      endDate == null &&
      minimumAmount == null &&
      maximumAmount == null &&
      minimumQuantity == null &&
      maximumQuantity == null &&
      workType == WorkTypeFilter.all &&
      periodStatus == PeriodStatusFilter.all &&
      status == WorkStatusFilter.all;
}
