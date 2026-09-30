import 'package:flowledger/models/model_converters.dart';

class Client {
  const Client({
    required this.id,
    required this.name,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String name;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  DatabaseRow toMap() => {
        'id': id,
        'name': name,
        'notes': notes,
        'is_active': isActive ? 1 : 0,
        'created_at': isoDate(createdAt),
        'updated_at': isoDate(updatedAt),
        'deleted_at': deletedAt == null ? null : isoDate(deletedAt!),
      };

  factory Client.fromMap(DatabaseRow map) => Client(
        id: map['id']! as String,
        name: map['name']! as String,
        notes: map['notes'] as String?,
        isActive: boolFromDatabase(map['is_active']),
        createdAt: dateFromDatabase(map['created_at']),
        updatedAt: dateFromDatabase(map['updated_at']),
        deletedAt: nullableDateFromDatabase(map['deleted_at']),
      );
}
