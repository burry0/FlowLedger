// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dashboard => 'Dashboard';

  @override
  String get clients => 'Clients';

  @override
  String get workItems => 'Work Items';

  @override
  String get periods => 'Periods';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get localDatabase => 'Local database';

  @override
  String get localOnlyDescription => 'Data is stored locally on this device.';

  @override
  String get cloudSyncOff => 'Cloud sync is disabled in this version.';

  @override
  String get addClient => 'Add Client';

  @override
  String get oneOffWork => 'One-off Work';

  @override
  String get recordPayment => 'Record Payment';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Try again';

  @override
  String get open => 'Open';

  @override
  String get view => 'View';

  @override
  String get filters => 'Filters';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get client => 'Client';

  @override
  String get category => 'Category';

  @override
  String get allClients => 'All clients';

  @override
  String get allCategories => 'All categories';

  @override
  String get amount => 'Amount';

  @override
  String get quantity => 'Quantity';

  @override
  String get notes => 'Notes';

  @override
  String get paymentDate => 'Payment date';

  @override
  String get activePeriod => 'Active Period';

  @override
  String get closedPeriod => 'Closed period';

  @override
  String get readOnly => 'Read-only';

  @override
  String get periodCategories => 'Period Categories';

  @override
  String get completed => 'Completed';

  @override
  String get edit => 'Edit';

  @override
  String get totalOpenReceivable => 'Total Open Receivable';

  @override
  String get activeClients => 'Active Clients';

  @override
  String get workCompletedThisMonth => 'Work Completed This Month';

  @override
  String get paymentsReceivedThisMonth => 'Payments Received This Month';

  @override
  String get clientsWithBalances => 'Clients With Open Balances';

  @override
  String get noClientBalances => 'No clients have an open balance.';

  @override
  String get noClients => 'No clients found';

  @override
  String get addFirstClient => 'Add your first client to start tracking work.';

  @override
  String get noWorkItems => 'No work items yet.';

  @override
  String get noPeriods => 'No periods to show.';

  @override
  String get clientName => 'Client name';

  @override
  String get workTitle => 'Work title';

  @override
  String get price => 'Price';

  @override
  String get add => 'Add';

  @override
  String get editWorkItem => 'Edit Work Item';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get addCategory => 'Add Category';

  @override
  String get defaultCategories => 'Default Categories';

  @override
  String get quickAddWork => 'Quick Add Work';

  @override
  String get payment => 'Payment';

  @override
  String get deleteClientTitle => 'Delete client?';

  @override
  String get deleteClientMessage =>
      'This client will be removed from normal lists. Related work and periods may remain as history.';

  @override
  String get deleteWorkTitle => 'Delete work item?';

  @override
  String get deleteWorkMessage =>
      'This work item will be removed from the active period total.';

  @override
  String get deletePeriodTitle => 'Delete period?';

  @override
  String get deletePeriodMessage =>
      'This period will be removed from normal lists. This may affect period totals.';

  @override
  String get select => 'Select';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get minimumAmount => 'Minimum amount';

  @override
  String get maximumAmount => 'Maximum amount';

  @override
  String get minimumQuantity => 'Minimum quantity';

  @override
  String get maximumQuantity => 'Maximum quantity';

  @override
  String get workType => 'Work type';

  @override
  String get periodStatus => 'Period status';

  @override
  String get all => 'All';

  @override
  String get categorizedWork => 'Categorized Work';

  @override
  String get filteredTotal => 'Filtered Total';

  @override
  String get workCount => 'Work Count';

  @override
  String get status => 'Status';

  @override
  String get date => 'Date';

  @override
  String get selectClient => 'Select Client';

  @override
  String get addOneOffWork => 'Add One-off Work';

  @override
  String get noCategoriesForClient =>
      'This client has no categories. You can add a one-off work item or create a category from the client page.';

  @override
  String get clientRequired => 'Please select a client.';

  @override
  String get workItemAdded => 'Work item added.';

  @override
  String get workItemAddFailed =>
      'Work item could not be added. Please try again.';

  @override
  String get workItemDeleteFailed =>
      'Work item could not be deleted. Please try again.';

  @override
  String get workStages => 'Work Stages';

  @override
  String get addStage => 'Add Stage';

  @override
  String get inProgress => 'In Progress';

  @override
  String get markAsCompleted => 'Mark as Completed';

  @override
  String get receivable => 'Receivable';

  @override
  String get notAllStagesCompleted => 'Not all stages are completed';

  @override
  String get completeInProgressBeforeClosing =>
      'Complete or delete in-progress work items before closing the period';

  @override
  String get createAsCompleted => 'Create as completed';

  @override
  String get workStagesHelper =>
      'These stages are copied as a checklist to work items created from this category.';

  @override
  String get revisions => 'Revisions';

  @override
  String get revisionHistory => 'History';

  @override
  String get versions => 'Versions';

  @override
  String get feedback => 'Feedback';

  @override
  String get newVersion => 'New Version';

  @override
  String get editVersion => 'Edit Version';

  @override
  String get versionLabel => 'Version name';

  @override
  String versionLabelHint(String label) {
    return 'Leave empty to use $label';
  }

  @override
  String get versionNotes => 'What changed';

  @override
  String get versionLink => 'File or link';

  @override
  String get versionStatusDraft => 'Draft';

  @override
  String get versionStatusSent => 'Sent';

  @override
  String get versionStatusApproved => 'Approved';

  @override
  String get deliverableNoVersions => 'No versions yet';

  @override
  String get deliverableWaiting => 'Waiting for feedback';

  @override
  String get deliverableChangesRequested => 'Changes requested';

  @override
  String get latestVersion => 'Latest';

  @override
  String deletedVersionLabel(String label) {
    return '$label (deleted)';
  }

  @override
  String deleteVersionConfirm(String label) {
    return 'Delete $label? Linked feedback is kept.';
  }

  @override
  String get addFeedback => 'Add Feedback';

  @override
  String get editFeedback => 'Edit Feedback';

  @override
  String get feedbackBody => 'Request';

  @override
  String get feedbackKindRevision => 'Revision';

  @override
  String get feedbackKindNewScope => 'New Scope';

  @override
  String get feedbackTimecode => 'Timecode (optional)';

  @override
  String get feedbackTimecodeHint => 'e.g. 00:43';

  @override
  String get feedbackVersion => 'Related version';

  @override
  String get feedbackGeneral => 'General (whole work item)';

  @override
  String get feedbackStatusOpen => 'Open';

  @override
  String get feedbackStatusResolved => 'Resolved';

  @override
  String get feedbackStatusWontDo => 'Won\'t do';

  @override
  String get markResolved => 'Mark resolved';

  @override
  String get markWontDo => 'Mark as won\'t do';

  @override
  String get reopen => 'Reopen';

  @override
  String get deleteFeedbackConfirm => 'Delete this feedback?';

  @override
  String get noOpenFeedback => 'No open feedback.';

  @override
  String get noFeedback => 'No feedback yet.';

  @override
  String openRevisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open revisions',
      one: '1 open revision',
    );
    return '$_temp0';
  }

  @override
  String openNewScopeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new scope requests',
      one: '1 new scope request',
    );
    return '$_temp0';
  }

  @override
  String feedbackCounts(int open, int total) {
    return '$open open · $total total';
  }

  @override
  String get revisionFinancialNote =>
      'Revision records do not change amounts, payments or the work status.';

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied.';

  @override
  String get revisionSaveFailed => 'Could not save. Please try again.';

  @override
  String get workItemNotFound => 'This work item could not be found.';

  @override
  String get historyWorkItemCreated => 'Work item created';

  @override
  String historyStepCompleted(String title) {
    return 'Stage completed: $title';
  }

  @override
  String get historyWorkItemCompleted => 'Work item completed';

  @override
  String historyVersionCreated(String label) {
    return '$label created';
  }

  @override
  String historyVersionSent(String label) {
    return '$label sent';
  }

  @override
  String historyVersionApproved(String label) {
    return '$label approved';
  }

  @override
  String get historyRevisionRequested => 'Revision requested';

  @override
  String get historyNewScopeRequested => 'New scope requested';

  @override
  String get historyFeedbackResolved => 'Feedback resolved';

  @override
  String get historyFeedbackWontDo => 'Feedback closed as won\'t do';

  @override
  String get historyEmpty => 'No history yet.';

  @override
  String get historyLimitationNote =>
      'History is derived from current records. For repeated status changes only the latest time is kept, and deleted records are not shown.';

  @override
  String get multiplier => 'Multiplier';

  @override
  String get validQuantityRequired => 'Enter a valid quantity.';

  @override
  String get workTitleRequired => 'Work title is required.';

  @override
  String get workItemUpdated => 'Work item updated.';

  @override
  String get workItemUpdateFailed =>
      'Work item could not be updated. Please try again.';

  @override
  String get openRevisions => 'Open revisions';

  @override
  String get awaitingFeedback => 'Awaiting feedback';

  @override
  String workItemCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get backupTitle => 'Backup';

  @override
  String get backupDescription =>
      'Save all data to a single file, or restore from one. Keep backups outside this computer too.';

  @override
  String get createBackup => 'Create backup';

  @override
  String get restoreBackup => 'Restore from backup';

  @override
  String backupSaved(String path) {
    return 'Backup saved: $path';
  }

  @override
  String get backupFailed => 'Backup could not be created.';

  @override
  String get restoreConfirmTitle => 'Restore this backup?';

  @override
  String restoreConfirmMessage(int clients, int workItems) {
    return 'The backup contains $clients clients and $workItems work items. It will replace all current data. Your current data is saved to a safety copy first.';
  }

  @override
  String get restoreAction => 'Restore';

  @override
  String restoreSucceeded(String path) {
    return 'Backup restored. Previous data saved to: $path';
  }

  @override
  String get restoreFailed =>
      'Backup could not be restored. Your data was not changed.';

  @override
  String get backupNotFound => 'The selected file could not be found.';

  @override
  String get backupInvalid => 'This file is not a valid FlowLedger backup.';

  @override
  String get backupNewer =>
      'This backup was created by a newer FlowLedger version. Update the app first.';

  @override
  String get backupCorrupted =>
      'This backup file is damaged and cannot be restored.';

  @override
  String get backupFileType => 'FlowLedger backup';

  @override
  String get currency => 'Currency';

  @override
  String get currencyHelper =>
      'Only changes how amounts are shown; stored amounts are not converted.';

  @override
  String get oneOffWorkTitle => 'One-off Custom Work';

  @override
  String get workTitleRequiredShort => 'Work title is required.';

  @override
  String get note => 'Note';

  @override
  String get addWorkAction => 'Add Work';

  @override
  String get validAmountRequired => 'Enter a valid amount.';

  @override
  String get paymentReceivedTitle => 'Payment Received';

  @override
  String get closePeriodAction => 'Close Period';

  @override
  String get amountMustBePositive => 'Amount must be greater than zero.';

  @override
  String get amountExceedsRemaining =>
      'Amount cannot exceed the remaining balance.';

  @override
  String get periodOngoing => 'Ongoing';

  @override
  String get totalWork => 'Total Work';

  @override
  String get paidAmount => 'Paid Amount';

  @override
  String get remainingAmountLabel => 'Remaining Amount';

  @override
  String get workItemCountTitle => 'Work Items';

  @override
  String get periodDeleteFailed =>
      'Period could not be deleted. Please try again.';

  @override
  String get periodTotal => 'Period Total';

  @override
  String get totalWorkAmount => 'Total Work Amount';

  @override
  String get periodCategoriesTitle => 'Period Categories';

  @override
  String get noCategorySnapshot => 'No category snapshot in this period.';

  @override
  String get worksTitle => 'Work';

  @override
  String get noWorkInPeriod => 'No work items in this period.';

  @override
  String get paymentRecordTitle => 'Payments';

  @override
  String get noPaymentsInPeriod => 'No payments for this period.';

  @override
  String get periodDetailsLoadFailed => 'Period details could not be loaded.';

  @override
  String get openPeriodChip => 'Open Period';

  @override
  String get closedPeriodTitle => 'Closed Period';

  @override
  String get periodReviewTitle => 'Period Review';

  @override
  String get goToClientDetail => 'Go to Client';

  @override
  String quantityWithUnit(String quantity) {
    return '$quantity pcs';
  }

  @override
  String get clientDeleteFailed =>
      'Client could not be deleted. Please try again.';

  @override
  String lastPayment(String date) {
    return 'Last payment: $date';
  }

  @override
  String get clientSaveFailed => 'Client could not be saved. Please try again.';

  @override
  String get clientNameRequired => 'Client name is required.';

  @override
  String get stageUpdateFailed => 'Stage could not be updated.';

  @override
  String get confirmCompleteWithOpenStages =>
      'Not all stages are completed. Mark the work as completed anyway?';

  @override
  String get workCompleteFailed => 'Work could not be completed.';

  @override
  String get noStagesForWork => 'This work item has no stages.';

  @override
  String stagesProgress(int done, int total) {
    return '$done/$total completed';
  }

  @override
  String exportSaved(String format) {
    return '$format export saved.';
  }

  @override
  String get exportFailed => 'Active period export could not be saved.';

  @override
  String remainingPaymentHelper(String amount) {
    return 'Remaining: $amount';
  }

  @override
  String get paymentRecordedNewPeriod =>
      'Payment recorded, a new period was opened.';

  @override
  String get noRemainingPayment => 'No remaining payment for this period.';

  @override
  String get partialPaymentTitle => 'Partial Payment Received';

  @override
  String get savePartialPayment => 'Save Partial Payment';

  @override
  String partialPaymentHelper(String amount) {
    return 'The period stays open. Remaining: $amount';
  }

  @override
  String get partialPaymentSaved => 'Partial payment recorded.';

  @override
  String get partialPaymentFailed =>
      'Partial payment could not be recorded. Please try again.';

  @override
  String categoryWorkAdded(String name) {
    return '$name added to work items.';
  }

  @override
  String get oneOffWorkAdded => 'One-off work added.';

  @override
  String get workItemDeleted => 'Work item deleted.';

  @override
  String get deleteCategoryTitle => 'Delete category';

  @override
  String deleteCategoryMessage(String name) {
    return 'Delete the “$name” category?\n\nPast periods are not affected.';
  }

  @override
  String get categoryDeleteFailed =>
      'Category could not be deleted. Please try again.';

  @override
  String get noClosedPeriods => 'No closed periods yet.';

  @override
  String get pastPeriods => 'Past Periods';

  @override
  String periodStartedSummary(String date, String total, String paid) {
    return 'Started $date · Total: $total · Received: $paid';
  }

  @override
  String get periodInfoLoading => 'Loading period info';

  @override
  String get exportTxt => 'Export TXT';

  @override
  String get exportXlsx => 'Export XLSX';

  @override
  String get partialPaymentButton => 'Record Partial Payment';

  @override
  String get pricesFixedNote =>
      'Prices in this list were fixed when the period opened.';

  @override
  String get periodCategoriesLoadFailed =>
      'Period categories could not be loaded.';

  @override
  String get noCategoriesInPeriod => 'No categories for this period.';

  @override
  String get workItemsLoadFailed => 'Work items could not be loaded.';

  @override
  String get noWorkItemsInPeriodYet => 'No work items in this period yet.';

  @override
  String get thisPeriodPayments => 'Payments This Period';

  @override
  String get paymentsLoadFailed => 'Payments could not be loaded.';

  @override
  String get defaultCategoriesNote =>
      'These categories are copied to new periods. They do not change prices in past periods.';

  @override
  String get pastPeriodsUnaffected => 'Past periods are not affected.';

  @override
  String get noDefaultCategories => 'No default categories yet.';

  @override
  String get categorySaveFailed =>
      'Category could not be saved. Please try again.';

  @override
  String get categoryName => 'Category name';

  @override
  String get categoryNameRequired => 'Category name is required.';

  @override
  String get validPriceRequired => 'Enter a valid price.';

  @override
  String get moveUp => 'Move up';

  @override
  String get moveDown => 'Move down';

  @override
  String get saving => 'Saving...';

  @override
  String get reportTitle => 'FlowLedger - Active Period Report';

  @override
  String get reportClient => 'Client';

  @override
  String get reportPeriodStart => 'Period start';

  @override
  String get reportDate => 'Report date';

  @override
  String get reportSummary => 'Summary';

  @override
  String get reportCompletedCount => 'Completed work';

  @override
  String get reportInProgressCount => 'Work in progress';

  @override
  String get reportCompletedTotal => 'Completed work total';

  @override
  String get reportInProgressTotal => 'Work in progress total';

  @override
  String get reportPaymentReceived => 'Payment received';

  @override
  String get reportRemaining => 'Remaining amount';

  @override
  String get reportWorkItems => 'Work items';

  @override
  String get reportPayments => 'Payments';

  @override
  String get reportColNo => 'No';

  @override
  String get reportColDate => 'Date';

  @override
  String get reportColWork => 'Work';

  @override
  String get reportColStatus => 'Status';

  @override
  String get reportColUnitPrice => 'Unit price';

  @override
  String get reportColQuantity => 'Quantity';

  @override
  String get reportColMultiplier => 'Multiplier';

  @override
  String get reportColAmount => 'Amount';

  @override
  String get reportColNotes => 'Notes';

  @override
  String get reportColNote => 'Note';

  @override
  String reportNotePrefix(String note) {
    return 'Note: $note';
  }

  @override
  String get reportSheetName => 'Active Period';

  @override
  String get reportTextFile => 'Text file';

  @override
  String get reportExcelFile => 'Excel workbook';

  @override
  String get reportFileSuffix => 'active_period';

  @override
  String get reportUnnamedClient => 'client';
}
