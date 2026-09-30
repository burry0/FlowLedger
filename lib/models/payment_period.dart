import 'package:flowledger/models/model_converters.dart';

class PaymentPeriod {
  const PaymentPeriod({
    required this.id,
    required this.clientId,
    required this.startDate,
    this.endDate,
    this.status = PaymentPeriodStatus.open,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String clientId;
  final DateTime startDate;
  final DateTime? endDate;
  final PaymentPeriodStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  DatabaseRow toMap() => {
        'id': id,
        'client_id': clientId,
        'start_date': isoDate(startDate),
        'end_date': endDate == null ? null : isoDate(endDate!),
        'status': status.name,
        'created_at': isoDate(createdAt),
        'updated_at': isoDate(updatedAt),
        'deleted_at': deletedAt == null ? null : isoDate(deletedAt!),
      };

  factory PaymentPeriod.fromMap(DatabaseRow map) => PaymentPeriod(
        id: map['id']! as String,
        clientId: map['client_id']! as String,
        startDate: dateFromDatabase(map['start_date']),
        endDate: nullableDateFromDatabase(map['end_date']),
        status: PaymentPeriodStatus.fromDatabase(map['status']! as String),
        createdAt: dateFromDatabase(map['created_at']),
        updatedAt: dateFromDatabase(map['updated_at']),
        deletedAt: nullableDateFromDatabase(map['deleted_at']),
      );
}

enum PaymentPeriodStatus {
  open,
  closed;

  static PaymentPeriodStatus fromDatabase(String value) {
    return PaymentPeriodStatus.values.byName(value);
  }
}
