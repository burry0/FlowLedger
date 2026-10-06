// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get dashboard => 'Übersicht';

  @override
  String get clients => 'Kunden';

  @override
  String get workItems => 'Aufträge';

  @override
  String get periods => 'Zeiträume';

  @override
  String get settings => 'Einstellungen';

  @override
  String get theme => 'Design';

  @override
  String get language => 'Sprache';

  @override
  String get system => 'System';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get localDatabase => 'Lokale Datenbank';

  @override
  String get localOnlyDescription =>
      'Daten werden lokal auf diesem Gerät gespeichert.';

  @override
  String get cloudSyncOff =>
      'Cloud-Synchronisierung ist in dieser Version deaktiviert.';

  @override
  String get addClient => 'Kunde hinzufügen';

  @override
  String get oneOffWork => 'Einzelauftrag';

  @override
  String get recordPayment => 'Zahlung erfassen';

  @override
  String get delete => 'Löschen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get open => 'Öffnen';

  @override
  String get view => 'Ansehen';

  @override
  String get filters => 'Filter';

  @override
  String get clearFilters => 'Filter zurücksetzen';

  @override
  String get client => 'Kunde';

  @override
  String get category => 'Kategorie';

  @override
  String get allClients => 'Alle Kunden';

  @override
  String get allCategories => 'Alle Kategorien';

  @override
  String get amount => 'Betrag';

  @override
  String get quantity => 'Menge';

  @override
  String get notes => 'Notizen';

  @override
  String get paymentDate => 'Zahlungsdatum';

  @override
  String get activePeriod => 'Aktiver Zeitraum';

  @override
  String get closedPeriod => 'Abgeschlossener Zeitraum';

  @override
  String get readOnly => 'Schreibgeschützt';

  @override
  String get periodCategories => 'Zeitraum-Kategorien';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get totalOpenReceivable => 'Offene Forderungen gesamt';

  @override
  String get activeClients => 'Aktive Kunden';

  @override
  String get workCompletedThisMonth => 'Diesen Monat abgeschlossen';

  @override
  String get paymentsReceivedThisMonth => 'Diesen Monat erhaltene Zahlungen';

  @override
  String get clientsWithBalances => 'Kunden mit offenem Saldo';

  @override
  String get noClientBalances => 'Kein Kunde hat einen offenen Saldo.';

  @override
  String get noClients => 'Keine Kunden gefunden';

  @override
  String get addFirstClient =>
      'Füge deinen ersten Kunden hinzu, um mit der Erfassung zu beginnen.';

  @override
  String get noWorkItems => 'Noch keine Aufträge.';

  @override
  String get noPeriods => 'Keine Zeiträume vorhanden.';

  @override
  String get clientName => 'Kundenname';

  @override
  String get workTitle => 'Auftragstitel';

  @override
  String get price => 'Preis';

  @override
  String get add => 'Hinzufügen';

  @override
  String get editWorkItem => 'Auftrag bearbeiten';

  @override
  String get editCategory => 'Kategorie bearbeiten';

  @override
  String get addCategory => 'Kategorie hinzufügen';

  @override
  String get defaultCategories => 'Standardkategorien';

  @override
  String get quickAddWork => 'Auftrag schnell hinzufügen';

  @override
  String get payment => 'Zahlung';

  @override
  String get deleteClientTitle => 'Kunde löschen?';

  @override
  String get deleteClientMessage =>
      'Dieser Kunde wird aus den normalen Listen entfernt. Zugehörige Aufträge und Zeiträume können als Verlauf erhalten bleiben.';

  @override
  String get deleteWorkTitle => 'Auftrag löschen?';

  @override
  String get deleteWorkMessage =>
      'Dieser Auftrag wird aus der Summe des aktiven Zeitraums entfernt.';

  @override
  String get deletePeriodTitle => 'Zeitraum löschen?';

  @override
  String get deletePeriodMessage =>
      'Dieser Zeitraum wird aus den normalen Listen entfernt. Das kann Zeitraumsummen beeinflussen.';

  @override
  String get select => 'Auswählen';

  @override
  String get startDate => 'Startdatum';

  @override
  String get endDate => 'Enddatum';

  @override
  String get minimumAmount => 'Mindestbetrag';

  @override
  String get maximumAmount => 'Höchstbetrag';

  @override
  String get minimumQuantity => 'Mindestmenge';

  @override
  String get maximumQuantity => 'Höchstmenge';

  @override
  String get workType => 'Auftragsart';

  @override
  String get periodStatus => 'Zeitraumstatus';

  @override
  String get all => 'Alle';

  @override
  String get categorizedWork => 'Kategorisierte Aufträge';

  @override
  String get filteredTotal => 'Gefilterte Summe';

  @override
  String get workCount => 'Anzahl Aufträge';

  @override
  String get status => 'Status';

  @override
  String get date => 'Datum';

  @override
  String get selectClient => 'Kunde auswählen';

  @override
  String get addOneOffWork => 'Einzelauftrag hinzufügen';

  @override
  String get noCategoriesForClient =>
      'Dieser Kunde hat keine Kategorien. Du kannst einen Einzelauftrag hinzufügen oder auf der Kundenseite eine Kategorie anlegen.';

  @override
  String get clientRequired => 'Bitte einen Kunden auswählen.';

  @override
  String get workItemAdded => 'Auftrag hinzugefügt.';

  @override
  String get workItemAddFailed =>
      'Auftrag konnte nicht hinzugefügt werden. Bitte erneut versuchen.';

  @override
  String get workItemDeleteFailed =>
      'Auftrag konnte nicht gelöscht werden. Bitte erneut versuchen.';

  @override
  String get workStages => 'Arbeitsschritte';

  @override
  String get addStage => 'Schritt hinzufügen';

  @override
  String get inProgress => 'In Arbeit';

  @override
  String get markAsCompleted => 'Als abgeschlossen markieren';

  @override
  String get receivable => 'Offener Betrag';

  @override
  String get notAllStagesCompleted => 'Nicht alle Schritte sind abgeschlossen';

  @override
  String get completeInProgressBeforeClosing =>
      'Schließe laufende Aufträge ab oder lösche sie, bevor du den Zeitraum abschließt';

  @override
  String get createAsCompleted => 'Als abgeschlossen anlegen';

  @override
  String get workStagesHelper =>
      'Diese Schritte werden als Checkliste in Aufträge aus dieser Kategorie übernommen.';

  @override
  String get revisions => 'Revisionen';

  @override
  String get revisionHistory => 'Verlauf';

  @override
  String get versions => 'Versionen';

  @override
  String get feedback => 'Feedback';

  @override
  String get newVersion => 'Neue Version';

  @override
  String get editVersion => 'Version bearbeiten';

  @override
  String get versionLabel => 'Versionsname';

  @override
  String versionLabelHint(String label) {
    return 'Leer lassen für $label';
  }

  @override
  String get versionNotes => 'Was hat sich geändert';

  @override
  String get versionLink => 'Datei oder Link';

  @override
  String get versionStatusDraft => 'Entwurf';

  @override
  String get versionStatusSent => 'Gesendet';

  @override
  String get versionStatusApproved => 'Freigegeben';

  @override
  String get deliverableNoVersions => 'Noch keine Versionen';

  @override
  String get deliverableWaiting => 'Wartet auf Feedback';

  @override
  String get deliverableChangesRequested => 'Änderungen angefordert';

  @override
  String get latestVersion => 'Aktuell';

  @override
  String deletedVersionLabel(String label) {
    return '$label (gelöscht)';
  }

  @override
  String deleteVersionConfirm(String label) {
    return '$label löschen? Verknüpftes Feedback bleibt erhalten.';
  }

  @override
  String get addFeedback => 'Feedback hinzufügen';

  @override
  String get editFeedback => 'Feedback bearbeiten';

  @override
  String get feedbackBody => 'Anfrage';

  @override
  String get feedbackKindRevision => 'Revision';

  @override
  String get feedbackKindNewScope => 'Neuer Umfang';

  @override
  String get feedbackTimecode => 'Timecode (optional)';

  @override
  String get feedbackTimecodeHint => 'z. B. 00:43';

  @override
  String get feedbackVersion => 'Zugehörige Version';

  @override
  String get feedbackGeneral => 'Allgemein (ganzer Auftrag)';

  @override
  String get feedbackStatusOpen => 'Offen';

  @override
  String get feedbackStatusResolved => 'Erledigt';

  @override
  String get feedbackStatusWontDo => 'Wird nicht umgesetzt';

  @override
  String get markResolved => 'Als erledigt markieren';

  @override
  String get markWontDo => 'Als „wird nicht umgesetzt“ markieren';

  @override
  String get reopen => 'Wieder öffnen';

  @override
  String get deleteFeedbackConfirm => 'Dieses Feedback löschen?';

  @override
  String get noOpenFeedback => 'Kein offenes Feedback.';

  @override
  String get noFeedback => 'Noch kein Feedback.';

  @override
  String openRevisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count offene Revisionen',
      one: '1 offene Revision',
    );
    return '$_temp0';
  }

  @override
  String openNewScopeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Anfragen für neuen Umfang',
      one: '1 Anfrage für neuen Umfang',
    );
    return '$_temp0';
  }

  @override
  String feedbackCounts(int open, int total) {
    return '$open offen · $total gesamt';
  }

  @override
  String get revisionFinancialNote =>
      'Revisionseinträge ändern weder Beträge noch Zahlungen oder den Auftragsstatus.';

  @override
  String get copyLink => 'Link kopieren';

  @override
  String get linkCopied => 'Link kopiert.';

  @override
  String get revisionSaveFailed =>
      'Speichern fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get workItemNotFound => 'Dieser Auftrag wurde nicht gefunden.';

  @override
  String get historyWorkItemCreated => 'Auftrag erstellt';

  @override
  String historyStepCompleted(String title) {
    return 'Schritt abgeschlossen: $title';
  }

  @override
  String get historyWorkItemCompleted => 'Auftrag abgeschlossen';

  @override
  String historyVersionCreated(String label) {
    return '$label erstellt';
  }

  @override
  String historyVersionSent(String label) {
    return '$label gesendet';
  }

  @override
  String historyVersionApproved(String label) {
    return '$label freigegeben';
  }

  @override
  String get historyRevisionRequested => 'Revision angefordert';

  @override
  String get historyNewScopeRequested => 'Neuer Umfang angefragt';

  @override
  String get historyFeedbackResolved => 'Feedback erledigt';

  @override
  String get historyFeedbackWontDo =>
      'Feedback als „wird nicht umgesetzt“ geschlossen';

  @override
  String get historyEmpty => 'Noch kein Verlauf.';

  @override
  String get historyLimitationNote =>
      'Der Verlauf wird aus den aktuellen Einträgen abgeleitet. Bei wiederholten Statuswechseln bleibt nur der letzte Zeitpunkt erhalten; gelöschte Einträge werden nicht angezeigt.';

  @override
  String get multiplier => 'Faktor';

  @override
  String get validQuantityRequired => 'Gib eine gültige Menge ein.';

  @override
  String get workTitleRequired => 'Auftragstitel ist erforderlich.';

  @override
  String get workItemUpdated => 'Auftrag aktualisiert.';

  @override
  String get workItemUpdateFailed =>
      'Auftrag konnte nicht aktualisiert werden. Bitte erneut versuchen.';

  @override
  String get openRevisions => 'Offene Revisionen';

  @override
  String get awaitingFeedback => 'Wartet auf Feedback';

  @override
  String workItemCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufträge',
      one: '1 Auftrag',
    );
    return '$_temp0';
  }

  @override
  String get backupTitle => 'Sicherung';

  @override
  String get backupDescription =>
      'Alle Daten in einer Datei sichern oder aus einer Sicherung wiederherstellen. Bewahre Sicherungen auch außerhalb dieses Computers auf.';

  @override
  String get createBackup => 'Sicherung erstellen';

  @override
  String get restoreBackup => 'Aus Sicherung wiederherstellen';

  @override
  String backupSaved(String path) {
    return 'Sicherung gespeichert: $path';
  }

  @override
  String get backupFailed => 'Sicherung konnte nicht erstellt werden.';

  @override
  String get restoreConfirmTitle => 'Diese Sicherung wiederherstellen?';

  @override
  String restoreConfirmMessage(int clients, int workItems) {
    return 'Die Sicherung enthält $clients Kunden und $workItems Aufträge. Sie ersetzt alle aktuellen Daten. Deine aktuellen Daten werden vorher in einer Sicherheitskopie gespeichert.';
  }

  @override
  String get restoreAction => 'Wiederherstellen';

  @override
  String restoreSucceeded(String path) {
    return 'Sicherung wiederhergestellt. Vorherige Daten gespeichert unter: $path';
  }

  @override
  String get restoreFailed =>
      'Sicherung konnte nicht wiederhergestellt werden. Deine Daten wurden nicht verändert.';

  @override
  String get backupNotFound => 'Die ausgewählte Datei wurde nicht gefunden.';

  @override
  String get backupInvalid =>
      'Diese Datei ist keine gültige FlowLedger-Sicherung.';

  @override
  String get backupNewer =>
      'Diese Sicherung wurde mit einer neueren FlowLedger-Version erstellt. Bitte zuerst die App aktualisieren.';

  @override
  String get backupCorrupted =>
      'Diese Sicherungsdatei ist beschädigt und kann nicht wiederhergestellt werden.';

  @override
  String get backupFileType => 'FlowLedger-Sicherung';

  @override
  String get currency => 'Währung';

  @override
  String get currencyHelper =>
      'Ändert nur die Anzeige von Beträgen; gespeicherte Beträge werden nicht umgerechnet.';

  @override
  String get oneOffWorkTitle => 'Individueller Einzelauftrag';

  @override
  String get workTitleRequiredShort => 'Auftragstitel ist erforderlich.';

  @override
  String get note => 'Notiz';

  @override
  String get addWorkAction => 'Auftrag hinzufügen';

  @override
  String get validAmountRequired => 'Gib einen gültigen Betrag ein.';

  @override
  String get paymentReceivedTitle => 'Zahlung erhalten';

  @override
  String get closePeriodAction => 'Zeitraum abschließen';

  @override
  String get amountMustBePositive => 'Der Betrag muss größer als null sein.';

  @override
  String get amountExceedsRemaining =>
      'Der Betrag darf den offenen Betrag nicht übersteigen.';

  @override
  String get periodOngoing => 'Laufend';

  @override
  String get totalWork => 'Aufträge gesamt';

  @override
  String get paidAmount => 'Bezahlter Betrag';

  @override
  String get remainingAmountLabel => 'Offener Betrag';

  @override
  String get workItemCountTitle => 'Anzahl Aufträge';

  @override
  String get periodDeleteFailed =>
      'Zeitraum konnte nicht gelöscht werden. Bitte erneut versuchen.';

  @override
  String get periodTotal => 'Zeitraumsumme';

  @override
  String get totalWorkAmount => 'Auftragssumme';

  @override
  String get periodCategoriesTitle => 'Zeitraum-Kategorien';

  @override
  String get noCategorySnapshot =>
      'In diesem Zeitraum gibt es keine Kategorie-Momentaufnahme.';

  @override
  String get worksTitle => 'Aufträge';

  @override
  String get noWorkInPeriod => 'In diesem Zeitraum gibt es keine Aufträge.';

  @override
  String get paymentRecordTitle => 'Zahlungen';

  @override
  String get noPaymentsInPeriod =>
      'Für diesen Zeitraum gibt es keine Zahlungen.';

  @override
  String get periodDetailsLoadFailed =>
      'Zeitraumdetails konnten nicht geladen werden.';

  @override
  String get openPeriodChip => 'Offener Zeitraum';

  @override
  String get closedPeriodTitle => 'Abgeschlossener Zeitraum';

  @override
  String get periodReviewTitle => 'Zeitraum-Übersicht';

  @override
  String get goToClientDetail => 'Zum Kunden';

  @override
  String quantityWithUnit(String quantity) {
    return '$quantity Stk.';
  }

  @override
  String get clientDeleteFailed =>
      'Kunde konnte nicht gelöscht werden. Bitte erneut versuchen.';

  @override
  String lastPayment(String date) {
    return 'Letzte Zahlung: $date';
  }

  @override
  String get clientSaveFailed =>
      'Kunde konnte nicht gespeichert werden. Bitte erneut versuchen.';

  @override
  String get clientNameRequired => 'Kundenname ist erforderlich.';

  @override
  String get stageUpdateFailed => 'Schritt konnte nicht aktualisiert werden.';

  @override
  String get confirmCompleteWithOpenStages =>
      'Nicht alle Schritte sind abgeschlossen. Den Auftrag trotzdem als abgeschlossen markieren?';

  @override
  String get workCompleteFailed => 'Auftrag konnte nicht abgeschlossen werden.';

  @override
  String get noStagesForWork => 'Dieser Auftrag hat keine Schritte.';

  @override
  String stagesProgress(int done, int total) {
    return '$done/$total abgeschlossen';
  }

  @override
  String exportSaved(String format) {
    return '$format-Export gespeichert.';
  }

  @override
  String get exportFailed =>
      'Export des aktiven Zeitraums konnte nicht gespeichert werden.';

  @override
  String remainingPaymentHelper(String amount) {
    return 'Offen: $amount';
  }

  @override
  String get paymentRecordedNewPeriod =>
      'Zahlung erfasst, ein neuer Zeitraum wurde eröffnet.';

  @override
  String get noRemainingPayment => 'Für diesen Zeitraum ist nichts mehr offen.';

  @override
  String get partialPaymentTitle => 'Teilzahlung erhalten';

  @override
  String get savePartialPayment => 'Teilzahlung speichern';

  @override
  String partialPaymentHelper(String amount) {
    return 'Der Zeitraum bleibt offen. Offen: $amount';
  }

  @override
  String get partialPaymentSaved => 'Teilzahlung erfasst.';

  @override
  String get partialPaymentFailed =>
      'Teilzahlung konnte nicht erfasst werden. Bitte erneut versuchen.';

  @override
  String get partialPaymentByAmount => 'Betrag eingeben';

  @override
  String get partialPaymentByWork => 'Arbeiten wählen';

  @override
  String get partialPaymentSelectHint =>
      'Wähle die abgeschlossenen Arbeiten, die diese Zahlung abdeckt.';

  @override
  String get partialPaymentNoUnpaidWork =>
      'In diesem Zeitraum gibt es keine unbezahlten abgeschlossenen Arbeiten.';

  @override
  String get partialPaymentSelectAtLeastOne =>
      'Wähle mindestens eine Arbeit aus.';

  @override
  String get selectedWorkTotal => 'Summe der gewählten Arbeiten';

  @override
  String workItemPaidOn(String date) {
    return 'Bezahlt am $date';
  }

  @override
  String get paidWorkEditWarning =>
      'Diese Arbeit ist als bezahlt markiert. Eine Änderung ändert die erfasste Zahlung nicht.';

  @override
  String get paidWorkDeleteWarning =>
      'Diese Arbeit ist als bezahlt markiert. Die Zahlung bleibt erfasst; nur die Arbeit wird entfernt.';

  @override
  String paymentCoversWork(String titles) {
    return 'Für: $titles';
  }

  @override
  String get draftToggle => 'Entwurf – der Rest folgt später';

  @override
  String get draftToggleHint =>
      'Einen Teil des Preises jetzt abrechnen, den Rest bei Fertigstellung.';

  @override
  String draftShareSplit(String now, String percent, String later) {
    return 'Jetzt $now ($percent) · Bei Fertigstellung $later';
  }

  @override
  String get draftLockedNote =>
      'Dieser Entwurf ist fertiggestellt; sein Anteil kann nicht mehr geändert werden.';

  @override
  String workItemDraftLabel(String percent) {
    return 'Entwurf $percent';
  }

  @override
  String workItemCompletionLabel(String percent) {
    return 'Fertigstellung $percent';
  }

  @override
  String get pendingCompletionsTitle => 'Offene Entwürfe';

  @override
  String get pendingCompletionsNote =>
      'Entwürfe aus allen Zeiträumen, deren Rest noch nicht abgerechnet ist.';

  @override
  String pendingCompletionSubtitle(String date, String percent) {
    return 'Entwurf vom $date · $percent abgerechnet';
  }

  @override
  String get completeDraftAction => 'Fertigstellen';

  @override
  String get completeDraftTitle => 'Entwurf fertigstellen?';

  @override
  String completeDraftMessage(String title, String amount) {
    return 'Der Rest von „$title“ ($amount) wird dem aktiven Zeitraum als abgeschlossene Arbeit hinzugefügt.';
  }

  @override
  String get draftCompleted =>
      'Fertigstellung zum aktiven Zeitraum hinzugefügt.';

  @override
  String get draftCompleteFailed =>
      'Der Entwurf konnte nicht fertiggestellt werden.';

  @override
  String categoryWorkAdded(String name) {
    return '$name zu den Aufträgen hinzugefügt.';
  }

  @override
  String get oneOffWorkAdded => 'Einzelauftrag hinzugefügt.';

  @override
  String get workItemDeleted => 'Auftrag gelöscht.';

  @override
  String get deleteCategoryTitle => 'Kategorie löschen';

  @override
  String deleteCategoryMessage(String name) {
    return 'Die Kategorie „$name“ löschen?\n\nVergangene Zeiträume sind nicht betroffen.';
  }

  @override
  String get categoryDeleteFailed =>
      'Kategorie konnte nicht gelöscht werden. Bitte erneut versuchen.';

  @override
  String get noClosedPeriods => 'Noch keine abgeschlossenen Zeiträume.';

  @override
  String get pastPeriods => 'Vergangene Zeiträume';

  @override
  String periodStartedSummary(String date, String total, String paid) {
    return 'Begonnen am $date · Summe: $total · Erhalten: $paid';
  }

  @override
  String get periodInfoLoading => 'Zeitraum wird geladen';

  @override
  String get exportTxt => 'TXT exportieren';

  @override
  String get exportXlsx => 'XLSX exportieren';

  @override
  String get partialPaymentButton => 'Teilzahlung erfassen';

  @override
  String get pricesFixedNote =>
      'Die Preise in dieser Liste wurden bei Eröffnung des Zeitraums festgeschrieben.';

  @override
  String get periodCategoriesLoadFailed =>
      'Zeitraum-Kategorien konnten nicht geladen werden.';

  @override
  String get noCategoriesInPeriod =>
      'Für diesen Zeitraum gibt es keine Kategorien.';

  @override
  String get workItemsLoadFailed => 'Aufträge konnten nicht geladen werden.';

  @override
  String get noWorkItemsInPeriodYet =>
      'In diesem Zeitraum gibt es noch keine Aufträge.';

  @override
  String get thisPeriodPayments => 'Zahlungen in diesem Zeitraum';

  @override
  String get paymentsLoadFailed => 'Zahlungen konnten nicht geladen werden.';

  @override
  String get defaultCategoriesNote =>
      'Diese Kategorien werden in neue Zeiträume übernommen. Preise vergangener Zeiträume ändern sich nicht.';

  @override
  String get pastPeriodsUnaffected =>
      'Vergangene Zeiträume sind nicht betroffen.';

  @override
  String get noDefaultCategories => 'Noch keine Standardkategorien.';

  @override
  String get categorySaveFailed =>
      'Kategorie konnte nicht gespeichert werden. Bitte erneut versuchen.';

  @override
  String get categoryName => 'Kategoriename';

  @override
  String get categoryNameRequired => 'Kategoriename ist erforderlich.';

  @override
  String get validPriceRequired => 'Gib einen gültigen Preis ein.';

  @override
  String get moveUp => 'Nach oben';

  @override
  String get moveDown => 'Nach unten';

  @override
  String get saving => 'Wird gespeichert …';

  @override
  String get reportTitle => 'FlowLedger – Bericht aktiver Zeitraum';

  @override
  String get reportClient => 'Kunde';

  @override
  String get reportPeriodStart => 'Beginn des Zeitraums';

  @override
  String get reportDate => 'Berichtsdatum';

  @override
  String get reportSummary => 'Zusammenfassung';

  @override
  String get reportCompletedCount => 'Abgeschlossene Aufträge';

  @override
  String get reportInProgressCount => 'Aufträge in Arbeit';

  @override
  String get reportCompletedTotal => 'Summe abgeschlossener Aufträge';

  @override
  String get reportInProgressTotal => 'Summe laufender Aufträge';

  @override
  String get reportPaymentReceived => 'Erhaltene Zahlung';

  @override
  String get reportRemaining => 'Offener Betrag';

  @override
  String get reportWorkItems => 'Aufträge';

  @override
  String get reportPayments => 'Zahlungen';

  @override
  String get reportColNo => 'Nr.';

  @override
  String get reportColDate => 'Datum';

  @override
  String get reportColWork => 'Auftrag';

  @override
  String get reportColStatus => 'Status';

  @override
  String get reportColUnitPrice => 'Einzelpreis';

  @override
  String get reportColQuantity => 'Menge';

  @override
  String get reportColMultiplier => 'Faktor';

  @override
  String get reportColAmount => 'Betrag';

  @override
  String get reportColNotes => 'Notizen';

  @override
  String get reportColNote => 'Notiz';

  @override
  String reportNotePrefix(String note) {
    return 'Notiz: $note';
  }

  @override
  String get reportSheetName => 'Aktiver Zeitraum';

  @override
  String get reportTextFile => 'Textdatei';

  @override
  String get reportExcelFile => 'Excel-Arbeitsmappe';

  @override
  String get reportFileSuffix => 'aktiver_zeitraum';

  @override
  String get reportUnnamedClient => 'kunde';
}
