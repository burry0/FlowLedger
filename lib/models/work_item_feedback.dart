import 'package:flowledger/models/model_converters.dart';

/// Client feedback on a work item or one of its versions. "New scope" is a
/// label only; it has no financial effect.
class WorkItemFeedback {
  const WorkItemFeedback({
    required this.id,
    required this.workItemId,
    this.versionId,
    required this.body,
    this.kind = WorkItemFeedbackKind.revision,
    this.status = WorkItemFeedbackStatus.open,
    this.timecode,
    this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String workItemId;

  /// Null for general feedback. Kept even if the version is deleted.
  final String? versionId;
  final String body;
  final WorkItemFeedbackKind kind;
  final WorkItemFeedbackStatus status;

  /// Free-form timecode, e.g. "00:43".
  final String? timecode;

  /// When it was resolved or marked won't do; cleared when reopened.
  final DateTime? resolvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isOpen => status == WorkItemFeedbackStatus.open;

  DatabaseRow toMap() => {
        'id': id,
        'work_item_id': workItemId,
        'version_id': versionId,
        'body': body,
        'kind': kind.databaseValue,
        'status': status.databaseValue,
        'timecode': timecode,
        'resolved_at': resolvedAt == null ? null : isoDate(resolvedAt!),
        'created_at': isoDate(createdAt),
        'updated_at': isoDate(updatedAt),
        'deleted_at': deletedAt == null ? null : isoDate(deletedAt!),
      };

  factory WorkItemFeedback.fromMap(DatabaseRow map) => WorkItemFeedback(
        id: map['id']! as String,
        workItemId: map['work_item_id']! as String,
        versionId: map['version_id'] as String?,
        body: map['body']! as String,
        kind: WorkItemFeedbackKind.fromDatabase(map['kind']! as String),
        status: WorkItemFeedbackStatus.fromDatabase(map['status']! as String),
        timecode: map['timecode'] as String?,
        resolvedAt: nullableDateFromDatabase(map['resolved_at']),
        createdAt: dateFromDatabase(map['created_at']),
        updatedAt: dateFromDatabase(map['updated_at']),
        deletedAt: nullableDateFromDatabase(map['deleted_at']),
      );
}

enum WorkItemFeedbackKind {
  revision('revision'),
  newScope('new_scope');

  const WorkItemFeedbackKind(this.databaseValue);

  final String databaseValue;

  static WorkItemFeedbackKind fromDatabase(String value) {
    for (final kind in values) {
      if (kind.databaseValue == value) return kind;
    }
    throw FormatException('Unknown feedback kind: $value');
  }
}

enum WorkItemFeedbackStatus {
  open('open'),
  resolved('resolved'),
  wontDo('wont_do');

  const WorkItemFeedbackStatus(this.databaseValue);

  final String databaseValue;

  static WorkItemFeedbackStatus fromDatabase(String value) {
    for (final status in values) {
      if (status.databaseValue == value) return status;
    }
    throw FormatException('Unknown feedback status: $value');
  }
}
