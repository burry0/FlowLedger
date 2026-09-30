import 'package:flowledger/models/model_converters.dart';

class WorkItem {
  const WorkItem({
    required this.id,
    required this.clientId,
    required this.paymentPeriodId,
    this.periodCategoryId,
    required this.title,
    required this.priceSnapshot,
    required this.quantity,
    required this.totalPrice,
    this.multiplier = 1,
    this.status = WorkItemStatus.completed,
    this.completedAt,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String clientId;
  final String paymentPeriodId;
  final String? periodCategoryId;
  final String title;
  final double priceSnapshot;
  final double quantity;
  final double totalPrice;

  /// Total = [priceSnapshot] × [quantity] × [multiplier]. Only written when
  /// editing; new rows use the column default (1), so it is not in [toMap].
  final double multiplier;
  final WorkItemStatus status;
  final DateTime? completedAt;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  DatabaseRow toMap() => {
        'id': id,
        'client_id': clientId,
        'payment_period_id': paymentPeriodId,
        'period_category_id': periodCategoryId,
        'title': title,
        'price_snapshot': priceSnapshot,
        'quantity': quantity,
        'total_price': totalPrice,
        'status': status.databaseValue,
        'completed_at': completedAt == null ? null : isoDate(completedAt!),
        'notes': notes,
        'created_at': isoDate(createdAt),
        'updated_at': isoDate(updatedAt),
        'deleted_at': deletedAt == null ? null : isoDate(deletedAt!),
      };

  factory WorkItem.fromMap(DatabaseRow map) => WorkItem(
        id: map['id']! as String,
        clientId: map['client_id']! as String,
        paymentPeriodId: map['payment_period_id']! as String,
        periodCategoryId: map['period_category_id'] as String?,
        title: map['title']! as String,
        priceSnapshot: (map['price_snapshot']! as num).toDouble(),
        quantity: (map['quantity']! as num).toDouble(),
        totalPrice: (map['total_price']! as num).toDouble(),
        multiplier: (map['multiplier'] as num?)?.toDouble() ?? 1,
        status: WorkItemStatus.fromDatabase(map['status']! as String),
        completedAt: nullableDateFromDatabase(map['completed_at']),
        notes: map['notes'] as String?,
        createdAt: dateFromDatabase(map['created_at']),
        updatedAt: dateFromDatabase(map['updated_at']),
        deletedAt: nullableDateFromDatabase(map['deleted_at']),
      );
}

enum WorkItemStatus {
  inProgress,
  completed;

  String get databaseValue {
    switch (this) {
      case WorkItemStatus.inProgress:
        return 'in_progress';
      case WorkItemStatus.completed:
        return 'completed';
    }
  }

  static WorkItemStatus fromDatabase(String value) {
    switch (value) {
      case 'in_progress':
        return WorkItemStatus.inProgress;
      case 'completed':
        return WorkItemStatus.completed;
      default:
        return WorkItemStatus.completed;
    }
  }
}
