import 'package:flowledger/models/model_converters.dart';
import 'package:flowledger/models/payment_period.dart';
import 'package:flowledger/models/work_item.dart';
import 'package:flowledger/models/work_item_feedback.dart';
import 'package:flowledger/models/work_item_revision_detail.dart';
import 'package:flowledger/models/work_item_revision_summary.dart';
import 'package:flowledger/models/work_item_step.dart';
import 'package:flowledger/models/work_item_version.dart';
import 'package:flowledger/services/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// Versions and feedback of work items.
///
/// Writes only to `work_item_versions` and `work_item_feedback`; work status,
/// amounts, payments and periods are never changed. Records can be added to
/// work in closed periods; only deleted work, periods or clients are refused.
class RevisionRepository {
  RevisionRepository({DatabaseHelper? databaseHelper, Uuid? uuid})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance,
        _uuid = uuid ?? const Uuid();

  final DatabaseHelper _databaseHelper;
  final Uuid _uuid;

  /// Chunk size that keeps batched queries under SQLite's variable limit.
  static const _summaryChunkSize = 500;

  Future<WorkItemRevisionDetail?> getRevisionDetail(String workItemId) async {
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery(
      '''
        SELECT work_items.*,
          clients.name AS client_name,
          payment_periods.status AS period_status
        FROM work_items
        INNER JOIN clients ON clients.id = work_items.client_id
        INNER JOIN payment_periods
          ON payment_periods.id = work_items.payment_period_id
        WHERE work_items.id = ?
          AND work_items.deleted_at IS NULL
          AND clients.deleted_at IS NULL
          AND payment_periods.deleted_at IS NULL
        LIMIT 1
      ''',
      [workItemId],
    );
    if (rows.isEmpty) {
      return null;
    }
    final row = rows.single;
    final steps = await db.query(
      'work_item_steps',
      where: 'work_item_id = ? AND deleted_at IS NULL',
      whereArgs: [workItemId],
      orderBy: 'sort_order ASC, created_at ASC',
    );
    final versions = await db.query(
      'work_item_versions',
      where: 'work_item_id = ?',
      whereArgs: [workItemId],
      orderBy: 'sequence_no DESC',
    );
    final feedback = await db.query(
      'work_item_feedback',
      where: 'work_item_id = ? AND deleted_at IS NULL',
      whereArgs: [workItemId],
      orderBy: 'created_at DESC, id ASC',
    );
    return WorkItemRevisionDetail(
      workItem: WorkItem.fromMap(row),
      clientName: row['client_name']! as String,
      periodStatus:
          PaymentPeriodStatus.fromDatabase(row['period_status']! as String),
      steps: steps.map(WorkItemStep.fromMap).toList(),
      allVersions: versions.map(WorkItemVersion.fromMap).toList(),
      feedback: feedback.map(WorkItemFeedback.fromMap).toList(),
    );
  }

  /// Summaries for list screens, one query per chunk. Work items without
  /// records get an empty summary.
  Future<Map<String, WorkItemRevisionSummary>> getSummaries(
    Iterable<String> workItemIds,
  ) async {
    final ids = workItemIds.toSet().toList();
    final result = <String, WorkItemRevisionSummary>{};
    if (ids.isEmpty) {
      return result;
    }
    final db = await _databaseHelper.database;
    for (var start = 0; start < ids.length; start += _summaryChunkSize) {
      final chunk = ids.sublist(
        start,
        start + _summaryChunkSize > ids.length
            ? ids.length
            : start + _summaryChunkSize,
      );
      final placeholders = List.filled(chunk.length, '?').join(', ');
      final rows = await db.rawQuery(
        '''
          SELECT work_items.id AS work_item_id,
            (SELECT COUNT(*) FROM work_item_versions v
              WHERE v.work_item_id = work_items.id AND v.deleted_at IS NULL)
              AS version_count,
            (SELECT v.label FROM work_item_versions v
              WHERE v.work_item_id = work_items.id AND v.deleted_at IS NULL
              ORDER BY v.sequence_no DESC LIMIT 1) AS latest_label,
            (SELECT v.status FROM work_item_versions v
              WHERE v.work_item_id = work_items.id AND v.deleted_at IS NULL
              ORDER BY v.sequence_no DESC LIMIT 1) AS latest_status,
            (SELECT COUNT(*) FROM work_item_feedback f
              WHERE f.work_item_id = work_items.id AND f.deleted_at IS NULL
                AND f.status = 'open' AND f.kind = 'revision')
              AS open_revision_count,
            (SELECT COUNT(*) FROM work_item_feedback f
              WHERE f.work_item_id = work_items.id AND f.deleted_at IS NULL
                AND f.status = 'open' AND f.kind = 'new_scope')
              AS open_new_scope_count,
            (SELECT COUNT(*) FROM work_item_feedback f
              WHERE f.work_item_id = work_items.id AND f.deleted_at IS NULL)
              AS feedback_count
          FROM work_items
          WHERE work_items.id IN ($placeholders)
        ''',
        chunk,
      );
      for (final row in rows) {
        final id = row['work_item_id']! as String;
        final latestStatus = row['latest_status'] as String?;
        result[id] = WorkItemRevisionSummary(
          workItemId: id,
          versionCount: (row['version_count']! as num).toInt(),
          latestLabel: row['latest_label'] as String?,
          latestStatus: latestStatus == null
              ? null
              : WorkItemVersionStatus.fromDatabase(latestStatus),
          openRevisionCount: (row['open_revision_count']! as num).toInt(),
          openNewScopeCount: (row['open_new_scope_count']! as num).toInt(),
          feedbackCount: (row['feedback_count']! as num).toInt(),
        );
      }
    }
    return result;
  }

  Future<WorkItemVersion> createVersion(
    String workItemId, {
    String? label,
    String? notes,
    String? link,
  }) async {
    final db = await _databaseHelper.database;
    return db.transaction((transaction) async {
      await _ensureLiveWorkItem(transaction, workItemId);
      final rows = await transaction.rawQuery(
        // Deleted versions count too, so a number is never reused.
        'SELECT COALESCE(MAX(sequence_no), 0) AS max_sequence '
        'FROM work_item_versions WHERE work_item_id = ?',
        [workItemId],
      );
      final sequenceNo = (rows.single['max_sequence']! as num).toInt() + 1;
      final now = DateTime.now();
      final version = WorkItemVersion(
        id: _uuid.v4(),
        workItemId: workItemId,
        sequenceNo: sequenceNo,
        label: _normalize(label) ?? 'V$sequenceNo',
        notes: _normalize(notes),
        link: _normalize(link),
        createdAt: now,
        updatedAt: now,
      );
      await transaction.insert(
        'work_item_versions',
        version.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return version;
    });
  }

  Future<void> updateVersion(
    String versionId, {
    required String label,
    String? notes,
    String? link,
  }) async {
    final normalizedLabel = _normalize(label);
    if (normalizedLabel == null) {
      throw ArgumentError.value(
          label, 'label', 'Version label cannot be empty.');
    }
    final db = await _databaseHelper.database;
    await db.transaction((transaction) async {
      await _getLiveVersion(transaction, versionId);
      await _updateSingle(
        transaction,
        'work_item_versions',
        versionId,
        {
          'label': normalizedLabel,
          'notes': _normalize(notes),
          'link': _normalize(link),
          'updated_at': isoDate(DateTime.now()),
        },
      );
    });
  }

  /// Timestamps record when the current status was entered: going back to
  /// draft clears `sent_at`, leaving approved clears `approved_at`. Earlier
  /// transitions are not kept.
  Future<void> setVersionStatus(
    String versionId,
    WorkItemVersionStatus status,
  ) async {
    final db = await _databaseHelper.database;
    await db.transaction((transaction) async {
      final current = await _getLiveVersion(transaction, versionId);
      if (current.status == status) {
        return;
      }
      final now = isoDate(DateTime.now());
      final changes = <String, Object?>{
        'status': status.databaseValue,
        'updated_at': now,
      };
      switch (status) {
        case WorkItemVersionStatus.draft:
          changes['sent_at'] = null;
          changes['approved_at'] = null;
        case WorkItemVersionStatus.sent:
          changes['sent_at'] = now;
          changes['approved_at'] = null;
        case WorkItemVersionStatus.approved:
          // Keep the existing value rather than invent a send time.
          changes['approved_at'] = now;
      }
      await _updateSingle(
          transaction, 'work_item_versions', versionId, changes);
    });
  }

  /// Soft-deletes the version. Linked feedback keeps its `version_id` and is
  /// shown with a "deleted version" label.
  Future<void> softDeleteVersion(String versionId) async {
    final db = await _databaseHelper.database;
    await db.transaction((transaction) async {
      await _getLiveVersion(transaction, versionId);
      final now = isoDate(DateTime.now());
      await _updateSingle(
        transaction,
        'work_item_versions',
        versionId,
        {'updated_at': now, 'deleted_at': now},
      );
    });
  }

  Future<WorkItemFeedback> createFeedback(
    String workItemId, {
    String? versionId,
    required String body,
    WorkItemFeedbackKind kind = WorkItemFeedbackKind.revision,
    String? timecode,
  }) async {
    final normalizedBody = _normalize(body);
    if (normalizedBody == null) {
      throw ArgumentError.value(body, 'body', 'Feedback cannot be empty.');
    }
    final db = await _databaseHelper.database;
    return db.transaction((transaction) async {
      await _ensureLiveWorkItem(transaction, workItemId);
      if (versionId != null) {
        await _ensureVersionBelongsTo(transaction, versionId, workItemId);
      }
      final now = DateTime.now();
      final feedback = WorkItemFeedback(
        id: _uuid.v4(),
        workItemId: workItemId,
        versionId: versionId,
        body: normalizedBody,
        kind: kind,
        timecode: _normalize(timecode),
        createdAt: now,
        updatedAt: now,
      );
      await transaction.insert(
        'work_item_feedback',
        feedback.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      return feedback;
    });
  }

  /// Updates text, kind, timecode and linked version. A link to a deleted
  /// version may be kept as is.
  Future<void> updateFeedback(
    String feedbackId, {
    required String body,
    required WorkItemFeedbackKind kind,
    String? timecode,
    String? versionId,
  }) async {
    final normalizedBody = _normalize(body);
    if (normalizedBody == null) {
      throw ArgumentError.value(body, 'body', 'Feedback cannot be empty.');
    }
    final db = await _databaseHelper.database;
    await db.transaction((transaction) async {
      final current = await _getLiveFeedback(transaction, feedbackId);
      if (versionId != null && versionId != current.versionId) {
        await _ensureVersionBelongsTo(
            transaction, versionId, current.workItemId);
      }
      await _updateSingle(
        transaction,
        'work_item_feedback',
        feedbackId,
        {
          'body': normalizedBody,
          'kind': kind.databaseValue,
          'timecode': _normalize(timecode),
          'version_id': versionId,
          'updated_at': isoDate(DateTime.now()),
        },
      );
    });
  }

  Future<void> setFeedbackStatus(
    String feedbackId,
    WorkItemFeedbackStatus status,
  ) async {
    final db = await _databaseHelper.database;
    await db.transaction((transaction) async {
      final current = await _getLiveFeedback(transaction, feedbackId);
      if (current.status == status) {
        return;
      }
      final now = isoDate(DateTime.now());
      await _updateSingle(
        transaction,
        'work_item_feedback',
        feedbackId,
        {
          'status': status.databaseValue,
          'resolved_at': status == WorkItemFeedbackStatus.open ? null : now,
          'updated_at': now,
        },
      );
    });
  }

  Future<void> softDeleteFeedback(String feedbackId) async {
    final db = await _databaseHelper.database;
    await db.transaction((transaction) async {
      await _getLiveFeedback(transaction, feedbackId);
      final now = isoDate(DateTime.now());
      await _updateSingle(
        transaction,
        'work_item_feedback',
        feedbackId,
        {'updated_at': now, 'deleted_at': now},
      );
    });
  }

  Future<void> _ensureLiveWorkItem(
    DatabaseExecutor executor,
    String workItemId,
  ) async {
    final rows = await executor.rawQuery(
      '''
        SELECT work_items.id
        FROM work_items
        INNER JOIN clients ON clients.id = work_items.client_id
        INNER JOIN payment_periods
          ON payment_periods.id = work_items.payment_period_id
        WHERE work_items.id = ?
          AND work_items.deleted_at IS NULL
          AND clients.deleted_at IS NULL
          AND payment_periods.deleted_at IS NULL
        LIMIT 1
      ''',
      [workItemId],
    );
    if (rows.isEmpty) {
      throw StateError('Work item not found or deleted.');
    }
  }

  Future<WorkItemVersion> _getLiveVersion(
    DatabaseExecutor executor,
    String versionId,
  ) async {
    final rows = await executor.query(
      'work_item_versions',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [versionId],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw StateError('Version not found or deleted.');
    }
    final version = WorkItemVersion.fromMap(rows.single);
    await _ensureLiveWorkItem(executor, version.workItemId);
    return version;
  }

  Future<void> _ensureVersionBelongsTo(
    DatabaseExecutor executor,
    String versionId,
    String workItemId,
  ) async {
    final version = await _getLiveVersion(executor, versionId);
    if (version.workItemId != workItemId) {
      throw ArgumentError.value(
        versionId,
        'versionId',
        'The version belongs to another work item.',
      );
    }
  }

  Future<WorkItemFeedback> _getLiveFeedback(
    DatabaseExecutor executor,
    String feedbackId,
  ) async {
    final rows = await executor.query(
      'work_item_feedback',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [feedbackId],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw StateError('Feedback not found or deleted.');
    }
    final feedback = WorkItemFeedback.fromMap(rows.single);
    await _ensureLiveWorkItem(executor, feedback.workItemId);
    return feedback;
  }

  Future<void> _updateSingle(
    DatabaseExecutor executor,
    String table,
    String id,
    Map<String, Object?> values,
  ) async {
    final affected = await executor.update(
      table,
      values,
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );
    if (affected != 1) {
      throw StateError('Could not update the record.');
    }
  }
}

String? _normalize(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
