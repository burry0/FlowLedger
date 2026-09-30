import 'package:flowledger/models/model_converters.dart';

/// A delivered version of a work item: V1, V2, Final… Has no financial
/// fields and never affects work status or period totals.
class WorkItemVersion {
  const WorkItemVersion({
    required this.id,
    required this.workItemId,
    required this.sequenceNo,
    required this.label,
    this.notes,
    this.link,
    this.status = WorkItemVersionStatus.draft,
    this.sentAt,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String workItemId;

  /// Increasing number per work item; never reused after a delete.
  final int sequenceNo;
  final String label;
  final String? notes;
  final String? link;
  final WorkItemVersionStatus status;

  /// When the version was last marked sent. Cleared when set back to draft.
  final DateTime? sentAt;

  /// When the version was last approved. Cleared when approval is undone.
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  DatabaseRow toMap() => {
        'id': id,
        'work_item_id': workItemId,
        'sequence_no': sequenceNo,
        'label': label,
        'notes': notes,
        'link': link,
        'status': status.databaseValue,
        'sent_at': sentAt == null ? null : isoDate(sentAt!),
        'approved_at': approvedAt == null ? null : isoDate(approvedAt!),
        'created_at': isoDate(createdAt),
        'updated_at': isoDate(updatedAt),
        'deleted_at': deletedAt == null ? null : isoDate(deletedAt!),
      };

  factory WorkItemVersion.fromMap(DatabaseRow map) => WorkItemVersion(
        id: map['id']! as String,
        workItemId: map['work_item_id']! as String,
        sequenceNo: (map['sequence_no']! as num).toInt(),
        label: map['label']! as String,
        notes: map['notes'] as String?,
        link: map['link'] as String?,
        status: WorkItemVersionStatus.fromDatabase(map['status']! as String),
        sentAt: nullableDateFromDatabase(map['sent_at']),
        approvedAt: nullableDateFromDatabase(map['approved_at']),
        createdAt: dateFromDatabase(map['created_at']),
        updatedAt: dateFromDatabase(map['updated_at']),
        deletedAt: nullableDateFromDatabase(map['deleted_at']),
      );
}

enum WorkItemVersionStatus {
  draft('draft'),
  sent('sent'),
  approved('approved');

  const WorkItemVersionStatus(this.databaseValue);

  final String databaseValue;

  /// Unknown values throw instead of silently mapping to a valid status.
  static WorkItemVersionStatus fromDatabase(String value) {
    for (final status in values) {
      if (status.databaseValue == value) return status;
    }
    throw FormatException('Unknown version status: $value');
  }
}
