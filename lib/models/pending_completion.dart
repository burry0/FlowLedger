import 'package:flowledger/models/work_item.dart';

/// A draft whose rest has not been billed yet.
class PendingCompletion {
  const PendingCompletion({required this.draft, required this.periodStartDate});

  final WorkItem draft;

  /// Start of the period the draft was billed in.
  final DateTime periodStartDate;

  double get billedShare => draft.billedShare;

  double get remainingShare => 1 - draft.billedShare;

  /// What completing the draft will add.
  double get remainingAmount => draft.fullPrice * remainingShare;
}
