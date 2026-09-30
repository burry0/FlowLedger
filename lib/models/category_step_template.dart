import 'package:flowledger/models/model_converters.dart';

class ClientDefaultCategoryStep {
  const ClientDefaultCategoryStep({
    required this.id,
    required this.clientId,
    required this.defaultCategoryId,
    required this.title,
    required this.sortOrder,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String clientId;
  final String defaultCategoryId;
  final String title;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  DatabaseRow toMap() => {
        'id': id,
        'client_id': clientId,
        'default_category_id': defaultCategoryId,
        'title': title,
        'sort_order': sortOrder,
        'is_active': isActive ? 1 : 0,
        'created_at': isoDate(createdAt),
        'updated_at': isoDate(updatedAt),
        'deleted_at': deletedAt == null ? null : isoDate(deletedAt!),
      };

  factory ClientDefaultCategoryStep.fromMap(DatabaseRow map) =>
      ClientDefaultCategoryStep(
        id: map['id']! as String,
        clientId: map['client_id']! as String,
        defaultCategoryId: map['default_category_id']! as String,
        title: map['title']! as String,
        sortOrder: (map['sort_order']! as num).toInt(),
        isActive: boolFromDatabase(map['is_active']),
        createdAt: dateFromDatabase(map['created_at']),
        updatedAt: dateFromDatabase(map['updated_at']),
        deletedAt: nullableDateFromDatabase(map['deleted_at']),
      );
}

class PeriodCategoryStep {
  const PeriodCategoryStep({
    required this.id,
    required this.clientId,
    required this.paymentPeriodId,
    required this.periodCategoryId,
    this.sourceDefaultStepId,
    required this.title,
    required this.sortOrder,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String clientId;
  final String paymentPeriodId;
  final String periodCategoryId;
  final String? sourceDefaultStepId;
  final String title;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  DatabaseRow toMap() => {
        'id': id,
        'client_id': clientId,
        'payment_period_id': paymentPeriodId,
        'period_category_id': periodCategoryId,
        'source_default_step_id': sourceDefaultStepId,
        'title': title,
        'sort_order': sortOrder,
        'is_active': isActive ? 1 : 0,
        'created_at': isoDate(createdAt),
        'updated_at': isoDate(updatedAt),
        'deleted_at': deletedAt == null ? null : isoDate(deletedAt!),
      };

  factory PeriodCategoryStep.fromMap(DatabaseRow map) => PeriodCategoryStep(
        id: map['id']! as String,
        clientId: map['client_id']! as String,
        paymentPeriodId: map['payment_period_id']! as String,
        periodCategoryId: map['period_category_id']! as String,
        sourceDefaultStepId: map['source_default_step_id'] as String?,
        title: map['title']! as String,
        sortOrder: (map['sort_order']! as num).toInt(),
        isActive: boolFromDatabase(map['is_active']),
        createdAt: dateFromDatabase(map['created_at']),
        updatedAt: dateFromDatabase(map['updated_at']),
        deletedAt: nullableDateFromDatabase(map['deleted_at']),
      );
}
