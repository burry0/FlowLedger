import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('ru'),
    Locale('tr')
  ];

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// No description provided for @workItems.
  ///
  /// In en, this message translates to:
  /// **'Work Items'**
  String get workItems;

  /// No description provided for @periods.
  ///
  /// In en, this message translates to:
  /// **'Periods'**
  String get periods;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @localDatabase.
  ///
  /// In en, this message translates to:
  /// **'Local database'**
  String get localDatabase;

  /// No description provided for @localOnlyDescription.
  ///
  /// In en, this message translates to:
  /// **'Data is stored locally on this device.'**
  String get localOnlyDescription;

  /// No description provided for @cloudSyncOff.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync is disabled in this version.'**
  String get cloudSyncOff;

  /// No description provided for @addClient.
  ///
  /// In en, this message translates to:
  /// **'Add Client'**
  String get addClient;

  /// No description provided for @oneOffWork.
  ///
  /// In en, this message translates to:
  /// **'One-off Work'**
  String get oneOffWork;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPayment;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @allClients.
  ///
  /// In en, this message translates to:
  /// **'All clients'**
  String get allClients;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment date'**
  String get paymentDate;

  /// No description provided for @activePeriod.
  ///
  /// In en, this message translates to:
  /// **'Active Period'**
  String get activePeriod;

  /// No description provided for @closedPeriod.
  ///
  /// In en, this message translates to:
  /// **'Closed period'**
  String get closedPeriod;

  /// No description provided for @readOnly.
  ///
  /// In en, this message translates to:
  /// **'Read-only'**
  String get readOnly;

  /// No description provided for @periodCategories.
  ///
  /// In en, this message translates to:
  /// **'Period Categories'**
  String get periodCategories;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @totalOpenReceivable.
  ///
  /// In en, this message translates to:
  /// **'Total Open Receivable'**
  String get totalOpenReceivable;

  /// No description provided for @activeClients.
  ///
  /// In en, this message translates to:
  /// **'Active Clients'**
  String get activeClients;

  /// No description provided for @workCompletedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Work Completed This Month'**
  String get workCompletedThisMonth;

  /// No description provided for @paymentsReceivedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Payments Received This Month'**
  String get paymentsReceivedThisMonth;

  /// No description provided for @clientsWithBalances.
  ///
  /// In en, this message translates to:
  /// **'Clients With Open Balances'**
  String get clientsWithBalances;

  /// No description provided for @noClientBalances.
  ///
  /// In en, this message translates to:
  /// **'No clients have an open balance.'**
  String get noClientBalances;

  /// No description provided for @noClients.
  ///
  /// In en, this message translates to:
  /// **'No clients found'**
  String get noClients;

  /// No description provided for @addFirstClient.
  ///
  /// In en, this message translates to:
  /// **'Add your first client to start tracking work.'**
  String get addFirstClient;

  /// No description provided for @noWorkItems.
  ///
  /// In en, this message translates to:
  /// **'No work items yet.'**
  String get noWorkItems;

  /// No description provided for @noPeriods.
  ///
  /// In en, this message translates to:
  /// **'No periods to show.'**
  String get noPeriods;

  /// No description provided for @clientName.
  ///
  /// In en, this message translates to:
  /// **'Client name'**
  String get clientName;

  /// No description provided for @workTitle.
  ///
  /// In en, this message translates to:
  /// **'Work title'**
  String get workTitle;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @editWorkItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Work Item'**
  String get editWorkItem;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @defaultCategories.
  ///
  /// In en, this message translates to:
  /// **'Default Categories'**
  String get defaultCategories;

  /// No description provided for @quickAddWork.
  ///
  /// In en, this message translates to:
  /// **'Quick Add Work'**
  String get quickAddWork;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @deleteClientTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete client?'**
  String get deleteClientTitle;

  /// No description provided for @deleteClientMessage.
  ///
  /// In en, this message translates to:
  /// **'This client will be removed from normal lists. Related work and periods may remain as history.'**
  String get deleteClientMessage;

  /// No description provided for @deleteWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete work item?'**
  String get deleteWorkTitle;

  /// No description provided for @deleteWorkMessage.
  ///
  /// In en, this message translates to:
  /// **'This work item will be removed from the active period total.'**
  String get deleteWorkMessage;

  /// No description provided for @deletePeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete period?'**
  String get deletePeriodTitle;

  /// No description provided for @deletePeriodMessage.
  ///
  /// In en, this message translates to:
  /// **'This period will be removed from normal lists. This may affect period totals.'**
  String get deletePeriodMessage;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @minimumAmount.
  ///
  /// In en, this message translates to:
  /// **'Minimum amount'**
  String get minimumAmount;

  /// No description provided for @maximumAmount.
  ///
  /// In en, this message translates to:
  /// **'Maximum amount'**
  String get maximumAmount;

  /// No description provided for @minimumQuantity.
  ///
  /// In en, this message translates to:
  /// **'Minimum quantity'**
  String get minimumQuantity;

  /// No description provided for @maximumQuantity.
  ///
  /// In en, this message translates to:
  /// **'Maximum quantity'**
  String get maximumQuantity;

  /// No description provided for @workType.
  ///
  /// In en, this message translates to:
  /// **'Work type'**
  String get workType;

  /// No description provided for @periodStatus.
  ///
  /// In en, this message translates to:
  /// **'Period status'**
  String get periodStatus;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @categorizedWork.
  ///
  /// In en, this message translates to:
  /// **'Categorized Work'**
  String get categorizedWork;

  /// No description provided for @filteredTotal.
  ///
  /// In en, this message translates to:
  /// **'Filtered Total'**
  String get filteredTotal;

  /// No description provided for @workCount.
  ///
  /// In en, this message translates to:
  /// **'Work Count'**
  String get workCount;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @selectClient.
  ///
  /// In en, this message translates to:
  /// **'Select Client'**
  String get selectClient;

  /// No description provided for @addOneOffWork.
  ///
  /// In en, this message translates to:
  /// **'Add One-off Work'**
  String get addOneOffWork;

  /// No description provided for @noCategoriesForClient.
  ///
  /// In en, this message translates to:
  /// **'This client has no categories. You can add a one-off work item or create a category from the client page.'**
  String get noCategoriesForClient;

  /// No description provided for @clientRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a client.'**
  String get clientRequired;

  /// No description provided for @workItemAdded.
  ///
  /// In en, this message translates to:
  /// **'Work item added.'**
  String get workItemAdded;

  /// No description provided for @workItemAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Work item could not be added. Please try again.'**
  String get workItemAddFailed;

  /// No description provided for @workItemDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Work item could not be deleted. Please try again.'**
  String get workItemDeleteFailed;

  /// No description provided for @workStages.
  ///
  /// In en, this message translates to:
  /// **'Work Stages'**
  String get workStages;

  /// No description provided for @addStage.
  ///
  /// In en, this message translates to:
  /// **'Add Stage'**
  String get addStage;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @markAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as Completed'**
  String get markAsCompleted;

  /// No description provided for @receivable.
  ///
  /// In en, this message translates to:
  /// **'Receivable'**
  String get receivable;

  /// No description provided for @notAllStagesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Not all stages are completed'**
  String get notAllStagesCompleted;

  /// No description provided for @completeInProgressBeforeClosing.
  ///
  /// In en, this message translates to:
  /// **'Complete or delete in-progress work items before closing the period'**
  String get completeInProgressBeforeClosing;

  /// No description provided for @createAsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Create as completed'**
  String get createAsCompleted;

  /// No description provided for @workStagesHelper.
  ///
  /// In en, this message translates to:
  /// **'These stages are copied as a checklist to work items created from this category.'**
  String get workStagesHelper;

  /// No description provided for @revisions.
  ///
  /// In en, this message translates to:
  /// **'Revisions'**
  String get revisions;

  /// No description provided for @revisionHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get revisionHistory;

  /// No description provided for @versions.
  ///
  /// In en, this message translates to:
  /// **'Versions'**
  String get versions;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @newVersion.
  ///
  /// In en, this message translates to:
  /// **'New Version'**
  String get newVersion;

  /// No description provided for @editVersion.
  ///
  /// In en, this message translates to:
  /// **'Edit Version'**
  String get editVersion;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version name'**
  String get versionLabel;

  /// No description provided for @versionLabelHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to use {label}'**
  String versionLabelHint(String label);

  /// No description provided for @versionNotes.
  ///
  /// In en, this message translates to:
  /// **'What changed'**
  String get versionNotes;

  /// No description provided for @versionLink.
  ///
  /// In en, this message translates to:
  /// **'File or link'**
  String get versionLink;

  /// No description provided for @versionStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get versionStatusDraft;

  /// No description provided for @versionStatusSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get versionStatusSent;

  /// No description provided for @versionStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get versionStatusApproved;

  /// No description provided for @deliverableNoVersions.
  ///
  /// In en, this message translates to:
  /// **'No versions yet'**
  String get deliverableNoVersions;

  /// No description provided for @deliverableWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for feedback'**
  String get deliverableWaiting;

  /// No description provided for @deliverableChangesRequested.
  ///
  /// In en, this message translates to:
  /// **'Changes requested'**
  String get deliverableChangesRequested;

  /// No description provided for @latestVersion.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latestVersion;

  /// No description provided for @deletedVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'{label} (deleted)'**
  String deletedVersionLabel(String label);

  /// No description provided for @deleteVersionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {label}? Linked feedback is kept.'**
  String deleteVersionConfirm(String label);

  /// No description provided for @addFeedback.
  ///
  /// In en, this message translates to:
  /// **'Add Feedback'**
  String get addFeedback;

  /// No description provided for @editFeedback.
  ///
  /// In en, this message translates to:
  /// **'Edit Feedback'**
  String get editFeedback;

  /// No description provided for @feedbackBody.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get feedbackBody;

  /// No description provided for @feedbackKindRevision.
  ///
  /// In en, this message translates to:
  /// **'Revision'**
  String get feedbackKindRevision;

  /// No description provided for @feedbackKindNewScope.
  ///
  /// In en, this message translates to:
  /// **'New Scope'**
  String get feedbackKindNewScope;

  /// No description provided for @feedbackTimecode.
  ///
  /// In en, this message translates to:
  /// **'Timecode (optional)'**
  String get feedbackTimecode;

  /// No description provided for @feedbackTimecodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 00:43'**
  String get feedbackTimecodeHint;

  /// No description provided for @feedbackVersion.
  ///
  /// In en, this message translates to:
  /// **'Related version'**
  String get feedbackVersion;

  /// No description provided for @feedbackGeneral.
  ///
  /// In en, this message translates to:
  /// **'General (whole work item)'**
  String get feedbackGeneral;

  /// No description provided for @feedbackStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get feedbackStatusOpen;

  /// No description provided for @feedbackStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get feedbackStatusResolved;

  /// No description provided for @feedbackStatusWontDo.
  ///
  /// In en, this message translates to:
  /// **'Won\'t do'**
  String get feedbackStatusWontDo;

  /// No description provided for @markResolved.
  ///
  /// In en, this message translates to:
  /// **'Mark resolved'**
  String get markResolved;

  /// No description provided for @markWontDo.
  ///
  /// In en, this message translates to:
  /// **'Mark as won\'t do'**
  String get markWontDo;

  /// No description provided for @reopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get reopen;

  /// No description provided for @deleteFeedbackConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this feedback?'**
  String get deleteFeedbackConfirm;

  /// No description provided for @noOpenFeedback.
  ///
  /// In en, this message translates to:
  /// **'No open feedback.'**
  String get noOpenFeedback;

  /// No description provided for @noFeedback.
  ///
  /// In en, this message translates to:
  /// **'No feedback yet.'**
  String get noFeedback;

  /// No description provided for @openRevisionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 open revision} other{{count} open revisions}}'**
  String openRevisionCount(int count);

  /// No description provided for @openNewScopeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 new scope request} other{{count} new scope requests}}'**
  String openNewScopeCount(int count);

  /// No description provided for @feedbackCounts.
  ///
  /// In en, this message translates to:
  /// **'{open} open · {total} total'**
  String feedbackCounts(int open, int total);

  /// No description provided for @revisionFinancialNote.
  ///
  /// In en, this message translates to:
  /// **'Revision records do not change amounts, payments or the work status.'**
  String get revisionFinancialNote;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied.'**
  String get linkCopied;

  /// No description provided for @revisionSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Please try again.'**
  String get revisionSaveFailed;

  /// No description provided for @workItemNotFound.
  ///
  /// In en, this message translates to:
  /// **'This work item could not be found.'**
  String get workItemNotFound;

  /// No description provided for @historyWorkItemCreated.
  ///
  /// In en, this message translates to:
  /// **'Work item created'**
  String get historyWorkItemCreated;

  /// No description provided for @historyStepCompleted.
  ///
  /// In en, this message translates to:
  /// **'Stage completed: {title}'**
  String historyStepCompleted(String title);

  /// No description provided for @historyWorkItemCompleted.
  ///
  /// In en, this message translates to:
  /// **'Work item completed'**
  String get historyWorkItemCompleted;

  /// No description provided for @historyVersionCreated.
  ///
  /// In en, this message translates to:
  /// **'{label} created'**
  String historyVersionCreated(String label);

  /// No description provided for @historyVersionSent.
  ///
  /// In en, this message translates to:
  /// **'{label} sent'**
  String historyVersionSent(String label);

  /// No description provided for @historyVersionApproved.
  ///
  /// In en, this message translates to:
  /// **'{label} approved'**
  String historyVersionApproved(String label);

  /// No description provided for @historyRevisionRequested.
  ///
  /// In en, this message translates to:
  /// **'Revision requested'**
  String get historyRevisionRequested;

  /// No description provided for @historyNewScopeRequested.
  ///
  /// In en, this message translates to:
  /// **'New scope requested'**
  String get historyNewScopeRequested;

  /// No description provided for @historyFeedbackResolved.
  ///
  /// In en, this message translates to:
  /// **'Feedback resolved'**
  String get historyFeedbackResolved;

  /// No description provided for @historyFeedbackWontDo.
  ///
  /// In en, this message translates to:
  /// **'Feedback closed as won\'t do'**
  String get historyFeedbackWontDo;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No history yet.'**
  String get historyEmpty;

  /// No description provided for @historyLimitationNote.
  ///
  /// In en, this message translates to:
  /// **'History is derived from current records. For repeated status changes only the latest time is kept, and deleted records are not shown.'**
  String get historyLimitationNote;

  /// No description provided for @multiplier.
  ///
  /// In en, this message translates to:
  /// **'Multiplier'**
  String get multiplier;

  /// No description provided for @validQuantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid quantity.'**
  String get validQuantityRequired;

  /// No description provided for @workTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Work title is required.'**
  String get workTitleRequired;

  /// No description provided for @workItemUpdated.
  ///
  /// In en, this message translates to:
  /// **'Work item updated.'**
  String get workItemUpdated;

  /// No description provided for @workItemUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Work item could not be updated. Please try again.'**
  String get workItemUpdateFailed;

  /// No description provided for @openRevisions.
  ///
  /// In en, this message translates to:
  /// **'Open revisions'**
  String get openRevisions;

  /// No description provided for @awaitingFeedback.
  ///
  /// In en, this message translates to:
  /// **'Awaiting feedback'**
  String get awaitingFeedback;

  /// No description provided for @workItemCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String workItemCountLabel(int count);

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupTitle;

  /// No description provided for @backupDescription.
  ///
  /// In en, this message translates to:
  /// **'Save all data to a single file, or restore from one. Keep backups outside this computer too.'**
  String get backupDescription;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get createBackup;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get restoreBackup;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved: {path}'**
  String backupSaved(String path);

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup could not be created.'**
  String get backupFailed;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore this backup?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'The backup contains {clients} clients and {workItems} work items. It will replace all current data. Your current data is saved to a safety copy first.'**
  String restoreConfirmMessage(int clients, int workItems);

  /// No description provided for @restoreAction.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreAction;

  /// No description provided for @restoreSucceeded.
  ///
  /// In en, this message translates to:
  /// **'Backup restored. Previous data saved to: {path}'**
  String restoreSucceeded(String path);

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup could not be restored. Your data was not changed.'**
  String get restoreFailed;

  /// No description provided for @backupNotFound.
  ///
  /// In en, this message translates to:
  /// **'The selected file could not be found.'**
  String get backupNotFound;

  /// No description provided for @backupInvalid.
  ///
  /// In en, this message translates to:
  /// **'This file is not a valid FlowLedger backup.'**
  String get backupInvalid;

  /// No description provided for @backupNewer.
  ///
  /// In en, this message translates to:
  /// **'This backup was created by a newer FlowLedger version. Update the app first.'**
  String get backupNewer;

  /// No description provided for @backupCorrupted.
  ///
  /// In en, this message translates to:
  /// **'This backup file is damaged and cannot be restored.'**
  String get backupCorrupted;

  /// No description provided for @backupFileType.
  ///
  /// In en, this message translates to:
  /// **'FlowLedger backup'**
  String get backupFileType;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @currencyHelper.
  ///
  /// In en, this message translates to:
  /// **'Only changes how amounts are shown; stored amounts are not converted.'**
  String get currencyHelper;

  /// No description provided for @oneOffWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'One-off Custom Work'**
  String get oneOffWorkTitle;

  /// No description provided for @workTitleRequiredShort.
  ///
  /// In en, this message translates to:
  /// **'Work title is required.'**
  String get workTitleRequiredShort;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @addWorkAction.
  ///
  /// In en, this message translates to:
  /// **'Add Work'**
  String get addWorkAction;

  /// No description provided for @validAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount.'**
  String get validAmountRequired;

  /// No description provided for @paymentReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Received'**
  String get paymentReceivedTitle;

  /// No description provided for @closePeriodAction.
  ///
  /// In en, this message translates to:
  /// **'Close Period'**
  String get closePeriodAction;

  /// No description provided for @amountMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than zero.'**
  String get amountMustBePositive;

  /// No description provided for @amountExceedsRemaining.
  ///
  /// In en, this message translates to:
  /// **'Amount cannot exceed the remaining balance.'**
  String get amountExceedsRemaining;

  /// No description provided for @periodOngoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get periodOngoing;

  /// No description provided for @totalWork.
  ///
  /// In en, this message translates to:
  /// **'Total Work'**
  String get totalWork;

  /// No description provided for @paidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid Amount'**
  String get paidAmount;

  /// No description provided for @remainingAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining Amount'**
  String get remainingAmountLabel;

  /// No description provided for @workItemCountTitle.
  ///
  /// In en, this message translates to:
  /// **'Work Items'**
  String get workItemCountTitle;

  /// No description provided for @periodDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Period could not be deleted. Please try again.'**
  String get periodDeleteFailed;

  /// No description provided for @periodTotal.
  ///
  /// In en, this message translates to:
  /// **'Period Total'**
  String get periodTotal;

  /// No description provided for @totalWorkAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Work Amount'**
  String get totalWorkAmount;

  /// No description provided for @periodCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Period Categories'**
  String get periodCategoriesTitle;

  /// No description provided for @noCategorySnapshot.
  ///
  /// In en, this message translates to:
  /// **'No category snapshot in this period.'**
  String get noCategorySnapshot;

  /// No description provided for @worksTitle.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get worksTitle;

  /// No description provided for @noWorkInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No work items in this period.'**
  String get noWorkInPeriod;

  /// No description provided for @paymentRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentRecordTitle;

  /// No description provided for @noPaymentsInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No payments for this period.'**
  String get noPaymentsInPeriod;

  /// No description provided for @periodDetailsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Period details could not be loaded.'**
  String get periodDetailsLoadFailed;

  /// No description provided for @openPeriodChip.
  ///
  /// In en, this message translates to:
  /// **'Open Period'**
  String get openPeriodChip;

  /// No description provided for @closedPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Closed Period'**
  String get closedPeriodTitle;

  /// No description provided for @periodReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Period Review'**
  String get periodReviewTitle;

  /// No description provided for @goToClientDetail.
  ///
  /// In en, this message translates to:
  /// **'Go to Client'**
  String get goToClientDetail;

  /// No description provided for @quantityWithUnit.
  ///
  /// In en, this message translates to:
  /// **'{quantity} pcs'**
  String quantityWithUnit(String quantity);

  /// No description provided for @clientDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Client could not be deleted. Please try again.'**
  String get clientDeleteFailed;

  /// No description provided for @lastPayment.
  ///
  /// In en, this message translates to:
  /// **'Last payment: {date}'**
  String lastPayment(String date);

  /// No description provided for @clientSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Client could not be saved. Please try again.'**
  String get clientSaveFailed;

  /// No description provided for @clientNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Client name is required.'**
  String get clientNameRequired;

  /// No description provided for @stageUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Stage could not be updated.'**
  String get stageUpdateFailed;

  /// No description provided for @confirmCompleteWithOpenStages.
  ///
  /// In en, this message translates to:
  /// **'Not all stages are completed. Mark the work as completed anyway?'**
  String get confirmCompleteWithOpenStages;

  /// No description provided for @workCompleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Work could not be completed.'**
  String get workCompleteFailed;

  /// No description provided for @noStagesForWork.
  ///
  /// In en, this message translates to:
  /// **'This work item has no stages.'**
  String get noStagesForWork;

  /// No description provided for @stagesProgress.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} completed'**
  String stagesProgress(int done, int total);

  /// No description provided for @exportSaved.
  ///
  /// In en, this message translates to:
  /// **'{format} export saved.'**
  String exportSaved(String format);

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Active period export could not be saved.'**
  String get exportFailed;

  /// No description provided for @remainingPaymentHelper.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {amount}'**
  String remainingPaymentHelper(String amount);

  /// No description provided for @paymentRecordedNewPeriod.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded, a new period was opened.'**
  String get paymentRecordedNewPeriod;

  /// No description provided for @noRemainingPayment.
  ///
  /// In en, this message translates to:
  /// **'No remaining payment for this period.'**
  String get noRemainingPayment;

  /// No description provided for @partialPaymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Partial Payment Received'**
  String get partialPaymentTitle;

  /// No description provided for @savePartialPayment.
  ///
  /// In en, this message translates to:
  /// **'Save Partial Payment'**
  String get savePartialPayment;

  /// No description provided for @partialPaymentHelper.
  ///
  /// In en, this message translates to:
  /// **'The period stays open. Remaining: {amount}'**
  String partialPaymentHelper(String amount);

  /// No description provided for @partialPaymentSaved.
  ///
  /// In en, this message translates to:
  /// **'Partial payment recorded.'**
  String get partialPaymentSaved;

  /// No description provided for @partialPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Partial payment could not be recorded. Please try again.'**
  String get partialPaymentFailed;

  /// No description provided for @partialPaymentByAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get partialPaymentByAmount;

  /// No description provided for @partialPaymentByWork.
  ///
  /// In en, this message translates to:
  /// **'Select work'**
  String get partialPaymentByWork;

  /// No description provided for @partialPaymentSelectHint.
  ///
  /// In en, this message translates to:
  /// **'Select the completed work this payment covers.'**
  String get partialPaymentSelectHint;

  /// No description provided for @partialPaymentNoUnpaidWork.
  ///
  /// In en, this message translates to:
  /// **'There is no unpaid completed work in this period.'**
  String get partialPaymentNoUnpaidWork;

  /// No description provided for @partialPaymentSelectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Select at least one work item.'**
  String get partialPaymentSelectAtLeastOne;

  /// No description provided for @selectedWorkTotal.
  ///
  /// In en, this message translates to:
  /// **'Selected work total'**
  String get selectedWorkTotal;

  /// No description provided for @workItemPaidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid {date}'**
  String workItemPaidOn(String date);

  /// No description provided for @paidWorkEditWarning.
  ///
  /// In en, this message translates to:
  /// **'This work is marked as paid. Changing it does not change the recorded payment.'**
  String get paidWorkEditWarning;

  /// No description provided for @paidWorkDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This work is marked as paid. The payment stays recorded; only the work is removed.'**
  String get paidWorkDeleteWarning;

  /// No description provided for @paymentCoversWork.
  ///
  /// In en, this message translates to:
  /// **'For: {titles}'**
  String paymentCoversWork(String titles);

  /// No description provided for @draftToggle.
  ///
  /// In en, this message translates to:
  /// **'Draft — the rest comes later'**
  String get draftToggle;

  /// No description provided for @draftToggleHint.
  ///
  /// In en, this message translates to:
  /// **'Bill part of the price now and the rest when you finish it.'**
  String get draftToggleHint;

  /// No description provided for @draftShareSplit.
  ///
  /// In en, this message translates to:
  /// **'Now {now} ({percent}) · On completion {later}'**
  String draftShareSplit(String now, String percent, String later);

  /// No description provided for @draftLockedNote.
  ///
  /// In en, this message translates to:
  /// **'This draft has been completed, so its share can no longer change.'**
  String get draftLockedNote;

  /// No description provided for @workItemDraftLabel.
  ///
  /// In en, this message translates to:
  /// **'Draft {percent}'**
  String workItemDraftLabel(String percent);

  /// No description provided for @workItemCompletionLabel.
  ///
  /// In en, this message translates to:
  /// **'Completion {percent}'**
  String workItemCompletionLabel(String percent);

  /// No description provided for @pendingCompletionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Drafts to complete'**
  String get pendingCompletionsTitle;

  /// No description provided for @pendingCompletionsNote.
  ///
  /// In en, this message translates to:
  /// **'Drafts from any period whose rest you have not billed yet.'**
  String get pendingCompletionsNote;

  /// No description provided for @pendingCompletionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Draft from {date} · {percent} billed'**
  String pendingCompletionSubtitle(String date, String percent);

  /// No description provided for @completeDraftAction.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeDraftAction;

  /// No description provided for @completeDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete draft?'**
  String get completeDraftTitle;

  /// No description provided for @completeDraftMessage.
  ///
  /// In en, this message translates to:
  /// **'The rest of “{title}” ({amount}) will be added to the active period as completed work.'**
  String completeDraftMessage(String title, String amount);

  /// No description provided for @draftCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completion added to the active period.'**
  String get draftCompleted;

  /// No description provided for @draftCompleteFailed.
  ///
  /// In en, this message translates to:
  /// **'The draft could not be completed.'**
  String get draftCompleteFailed;

  /// No description provided for @categoryWorkAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} added to work items.'**
  String categoryWorkAdded(String name);

  /// No description provided for @oneOffWorkAdded.
  ///
  /// In en, this message translates to:
  /// **'One-off work added.'**
  String get oneOffWorkAdded;

  /// No description provided for @workItemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Work item deleted.'**
  String get workItemDeleted;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete the “{name}” category?\n\nPast periods are not affected.'**
  String deleteCategoryMessage(String name);

  /// No description provided for @categoryDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Category could not be deleted. Please try again.'**
  String get categoryDeleteFailed;

  /// No description provided for @noClosedPeriods.
  ///
  /// In en, this message translates to:
  /// **'No closed periods yet.'**
  String get noClosedPeriods;

  /// No description provided for @pastPeriods.
  ///
  /// In en, this message translates to:
  /// **'Past Periods'**
  String get pastPeriods;

  /// No description provided for @periodStartedSummary.
  ///
  /// In en, this message translates to:
  /// **'Started {date} · Total: {total} · Received: {paid}'**
  String periodStartedSummary(String date, String total, String paid);

  /// No description provided for @periodInfoLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading period info'**
  String get periodInfoLoading;

  /// No description provided for @exportTxt.
  ///
  /// In en, this message translates to:
  /// **'Export TXT'**
  String get exportTxt;

  /// No description provided for @exportXlsx.
  ///
  /// In en, this message translates to:
  /// **'Export XLSX'**
  String get exportXlsx;

  /// No description provided for @partialPaymentButton.
  ///
  /// In en, this message translates to:
  /// **'Record Partial Payment'**
  String get partialPaymentButton;

  /// No description provided for @pricesFixedNote.
  ///
  /// In en, this message translates to:
  /// **'Prices in this list were fixed when the period opened.'**
  String get pricesFixedNote;

  /// No description provided for @periodCategoriesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Period categories could not be loaded.'**
  String get periodCategoriesLoadFailed;

  /// No description provided for @noCategoriesInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No categories for this period.'**
  String get noCategoriesInPeriod;

  /// No description provided for @workItemsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Work items could not be loaded.'**
  String get workItemsLoadFailed;

  /// No description provided for @noWorkItemsInPeriodYet.
  ///
  /// In en, this message translates to:
  /// **'No work items in this period yet.'**
  String get noWorkItemsInPeriodYet;

  /// No description provided for @thisPeriodPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments This Period'**
  String get thisPeriodPayments;

  /// No description provided for @paymentsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Payments could not be loaded.'**
  String get paymentsLoadFailed;

  /// No description provided for @defaultCategoriesNote.
  ///
  /// In en, this message translates to:
  /// **'These categories are copied to new periods. They do not change prices in past periods.'**
  String get defaultCategoriesNote;

  /// No description provided for @pastPeriodsUnaffected.
  ///
  /// In en, this message translates to:
  /// **'Past periods are not affected.'**
  String get pastPeriodsUnaffected;

  /// No description provided for @noDefaultCategories.
  ///
  /// In en, this message translates to:
  /// **'No default categories yet.'**
  String get noDefaultCategories;

  /// No description provided for @categorySaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Category could not be saved. Please try again.'**
  String get categorySaveFailed;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @categoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Category name is required.'**
  String get categoryNameRequired;

  /// No description provided for @validPriceRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid price.'**
  String get validPriceRequired;

  /// No description provided for @moveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get moveUp;

  /// No description provided for @moveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get moveDown;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'FlowLedger - Active Period Report'**
  String get reportTitle;

  /// No description provided for @reportClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get reportClient;

  /// No description provided for @reportPeriodStart.
  ///
  /// In en, this message translates to:
  /// **'Period start'**
  String get reportPeriodStart;

  /// No description provided for @reportDate.
  ///
  /// In en, this message translates to:
  /// **'Report date'**
  String get reportDate;

  /// No description provided for @reportSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get reportSummary;

  /// No description provided for @reportCompletedCount.
  ///
  /// In en, this message translates to:
  /// **'Completed work'**
  String get reportCompletedCount;

  /// No description provided for @reportInProgressCount.
  ///
  /// In en, this message translates to:
  /// **'Work in progress'**
  String get reportInProgressCount;

  /// No description provided for @reportCompletedTotal.
  ///
  /// In en, this message translates to:
  /// **'Completed work total'**
  String get reportCompletedTotal;

  /// No description provided for @reportInProgressTotal.
  ///
  /// In en, this message translates to:
  /// **'Work in progress total'**
  String get reportInProgressTotal;

  /// No description provided for @reportPaymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment received'**
  String get reportPaymentReceived;

  /// No description provided for @reportRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining amount'**
  String get reportRemaining;

  /// No description provided for @reportWorkItems.
  ///
  /// In en, this message translates to:
  /// **'Work items'**
  String get reportWorkItems;

  /// No description provided for @reportPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get reportPayments;

  /// No description provided for @reportColNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get reportColNo;

  /// No description provided for @reportColDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get reportColDate;

  /// No description provided for @reportColWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get reportColWork;

  /// No description provided for @reportColStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get reportColStatus;

  /// No description provided for @reportColUnitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get reportColUnitPrice;

  /// No description provided for @reportColQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get reportColQuantity;

  /// No description provided for @reportColMultiplier.
  ///
  /// In en, this message translates to:
  /// **'Multiplier'**
  String get reportColMultiplier;

  /// No description provided for @reportColAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get reportColAmount;

  /// No description provided for @reportColNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get reportColNotes;

  /// No description provided for @reportColNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get reportColNote;

  /// No description provided for @reportNotePrefix.
  ///
  /// In en, this message translates to:
  /// **'Note: {note}'**
  String reportNotePrefix(String note);

  /// No description provided for @reportSheetName.
  ///
  /// In en, this message translates to:
  /// **'Active Period'**
  String get reportSheetName;

  /// No description provided for @reportTextFile.
  ///
  /// In en, this message translates to:
  /// **'Text file'**
  String get reportTextFile;

  /// No description provided for @reportExcelFile.
  ///
  /// In en, this message translates to:
  /// **'Excel workbook'**
  String get reportExcelFile;

  /// No description provided for @reportFileSuffix.
  ///
  /// In en, this message translates to:
  /// **'active_period'**
  String get reportFileSuffix;

  /// No description provided for @reportUnnamedClient.
  ///
  /// In en, this message translates to:
  /// **'client'**
  String get reportUnnamedClient;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
