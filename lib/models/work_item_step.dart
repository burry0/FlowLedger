import 'package:flowledger/models/model_converters.dart';

class WorkItemStep {
  const WorkItemStep({
    required this.id,
    required this.workItemId,
    required this.title,
    required this.sortOrder,
    this.isDone = false,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String workItemId;
  final String title;
  final int sortOrder;
  final bool isDone;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  DatabaseRow toMap() => {
        'id': id,
        'work_item_id': workItemId,
        'title': title,
        'sort_order': sortOrder,
        'is_done': isDone ? 1 : 0,
        'completed_at': completedAt == null ? null : isoDate(completedAt!),
        'created_at': isoDate(createdAt),
        'updated_at': isoDate(updatedAt),
        'deleted_at': deletedAt == null ? null : isoDate(deletedAt!),
      };

  factory WorkItemStep.fromMap(DatabaseRow map) => WorkItemStep(
        id: map['id']! as String,
        workItemId: map['work_item_id']! as String,
        title: map['title']! as String,
        sortOrder: (map['sort_order']! as num).toInt(),
        isDone: boolFromDatabase(map['is_done']),
        completedAt: nullableDateFromDatabase(map['completed_at']),
        createdAt: dateFromDatabase(map['created_at']),
        updatedAt: dateFromDatabase(map['updated_at']),
        deletedAt: nullableDateFromDatabase(map['deleted_at']),
      );
}
