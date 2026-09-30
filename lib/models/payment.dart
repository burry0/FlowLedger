import 'package:flowledger/models/model_converters.dart';

class Payment {
  const Payment({
    required this.id,
    required this.clientId,
    required this.paymentPeriodId,
    required this.amount,
    required this.paidAt,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String clientId;
  final String paymentPeriodId;
  final double amount;
  final DateTime paidAt;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  DatabaseRow toMap() => {
        'id': id,
        'client_id': clientId,
        'payment_period_id': paymentPeriodId,
        'amount': amount,
        'paid_at': isoDate(paidAt),
        'note': note,
        'created_at': isoDate(createdAt),
        'updated_at': isoDate(updatedAt),
        'deleted_at': deletedAt == null ? null : isoDate(deletedAt!),
      };

  factory Payment.fromMap(DatabaseRow map) => Payment(
        id: map['id']! as String,
        clientId: map['client_id']! as String,
        paymentPeriodId: map['payment_period_id']! as String,
        amount: (map['amount']! as num).toDouble(),
        paidAt: dateFromDatabase(map['paid_at']),
        note: map['note'] as String?,
        createdAt: dateFromDatabase(map['created_at']),
        updatedAt: dateFromDatabase(map['updated_at']),
        deletedAt: nullableDateFromDatabase(map['deleted_at']),
      );
}
