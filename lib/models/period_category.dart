import 'package:flowledger/models/model_converters.dart';

/// Snapshot of a client's default category, taken when a period opens.
/// Never updated afterwards, so past prices and names are kept.
class PeriodCategory {
  const PeriodCategory({
    required this.id,
    required this.clientId,
    required this.paymentPeriodId,
    required this.name,
    required this.priceSnapshot,
    this.sourceDefaultCategoryId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String clientId;
  final String paymentPeriodId;
  final String? sourceDefaultCategoryId;
  final String name;
  final double priceSnapshot;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  DatabaseRow toMap() => {
        'id': id,
        'client_id': clientId,
        'payment_period_id': paymentPeriodId,
        'source_default_category_id': sourceDefaultCategoryId,
        'name': name,
        'price_snapshot': priceSnapshot,
        'is_active': isActive ? 1 : 0,
        'created_at': isoDate(createdAt),
        'updated_at': isoDate(updatedAt),
        'deleted_at': deletedAt == null ? null : isoDate(deletedAt!),
      };

  factory PeriodCategory.fromMap(DatabaseRow map) => PeriodCategory(
        id: map['id']! as String,
        clientId: map['client_id']! as String,
        paymentPeriodId: map['payment_period_id']! as String,
        sourceDefaultCategoryId: map['source_default_category_id'] as String?,
        name: map['name']! as String,
        priceSnapshot: (map['price_snapshot']! as num).toDouble(),
        isActive: boolFromDatabase(map['is_active']),
        createdAt: dateFromDatabase(map['created_at']),
        updatedAt: dateFromDatabase(map['updated_at']),
        deletedAt: nullableDateFromDatabase(map['deleted_at']),
      );
}
