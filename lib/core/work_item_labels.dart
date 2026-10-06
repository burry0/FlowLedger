import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/app_localizations.dart';
import 'package:flowledger/models/work_item.dart';

/// "Draft 50%" or "Completion 50%" for a work item billed in parts.
String? shareLabelFor(
  AppLocalizations strings,
  AppFormatter formatter,
  WorkItem workItem,
) {
  if (workItem.isCompletion) {
    return strings
        .workItemCompletionLabel(formatter.percent(workItem.billedShare));
  }
  if (workItem.isDraft) {
    return strings.workItemDraftLabel(formatter.percent(workItem.billedShare));
  }
  return null;
}
