import 'package:flowledger/models/model_converters.dart';

class ClientDefaultCategory {
  const ClientDefaultCategory({
    required this.id,
    required this.clientId,
    required this.name,
    required this.price,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String clientId;
  final String name;
  final double price;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  DatabaseRow toMap() => {
        'id': id,
        'client_id': clientId,
        'name': name,
        'price': price,
        'is_active': isActive ? 1 : 0,
        'created_at': isoDate(createdAt),
        'updated_at': isoDate(updatedAt),
        'deleted_at': deletedAt == null ? null : isoDate(deletedAt!),
      };

  factory ClientDefaultCategory.fromMap(DatabaseRow map) =>
      ClientDefaultCategory(
        id: map['id']! as String,
        clientId: map['client_id']! as String,
        name: map['name']! as String,
        price: (map['price']! as num).toDouble(),
        isActive: boolFromDatabase(map['is_active']),
        createdAt: dateFromDatabase(map['created_at']),
        updatedAt: dateFromDatabase(map['updated_at']),
        deletedAt: nullableDateFromDatabase(map['deleted_at']),
      );
}
