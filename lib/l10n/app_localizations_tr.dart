// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get dashboard => 'Dashboard';

  @override
  String get clients => 'Müşteriler';

  @override
  String get workItems => 'İşler';

  @override
  String get periods => 'Dönemler';

  @override
  String get settings => 'Ayarlar';

  @override
  String get theme => 'Tema';

  @override
  String get language => 'Dil';

  @override
  String get system => 'Sistem';

  @override
  String get light => 'Açık';

  @override
  String get dark => 'Koyu';

  @override
  String get localDatabase => 'Yerel veri tabanı';

  @override
  String get localOnlyDescription =>
      'Veriler bu cihazda yerel olarak saklanır.';

  @override
  String get cloudSyncOff => 'Bulut senkronizasyonu bu sürümde kapalıdır.';

  @override
  String get addClient => 'Müşteri Ekle';

  @override
  String get oneOffWork => 'Tek Seferlik İş';

  @override
  String get recordPayment => 'Ödeme Aldım';

  @override
  String get delete => 'Sil';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get save => 'Kaydet';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get open => 'Aç';

  @override
  String get view => 'İncele';

  @override
  String get filters => 'Filtreler';

  @override
  String get clearFilters => 'Filtreleri Temizle';

  @override
  String get client => 'Müşteri';

  @override
  String get category => 'Kategori';

  @override
  String get allClients => 'Tüm müşteriler';

  @override
  String get allCategories => 'Tüm kategoriler';

  @override
  String get amount => 'Tutar';

  @override
  String get quantity => 'Adet';

  @override
  String get notes => 'Notlar';

  @override
  String get paymentDate => 'Ödeme Tarihi';

  @override
  String get activePeriod => 'Aktif Dönem';

  @override
  String get closedPeriod => 'Kapalı dönem';

  @override
  String get readOnly => 'Salt Okunur';

  @override
  String get periodCategories => 'Dönem Kategorileri';

  @override
  String get completed => 'Tamamlandı';

  @override
  String get edit => 'Düzenle';

  @override
  String get totalOpenReceivable => 'Toplam Açık Alacak';

  @override
  String get activeClients => 'Aktif Müşteri';

  @override
  String get workCompletedThisMonth => 'Bu Ay Yapılan İş';

  @override
  String get paymentsReceivedThisMonth => 'Bu Ay Alınan Ödeme';

  @override
  String get clientsWithBalances => 'Açık Bakiyesi Olan Müşteriler';

  @override
  String get noClientBalances => 'Açık bakiyesi olan müşteri yok.';

  @override
  String get noClients => 'Müşteri bulunmuyor';

  @override
  String get addFirstClient =>
      'İlk müşterinizi ekleyerek çalışmaları takip etmeye başlayın.';

  @override
  String get noWorkItems => 'Henüz iş kaydı yok.';

  @override
  String get noPeriods => 'Gösterilecek dönem bulunmuyor.';

  @override
  String get clientName => 'Müşteri adı';

  @override
  String get workTitle => 'İş başlığı';

  @override
  String get price => 'Fiyat';

  @override
  String get add => 'Ekle';

  @override
  String get editWorkItem => 'İş Kaydını Düzenle';

  @override
  String get editCategory => 'Kategoriyi Düzenle';

  @override
  String get addCategory => 'Kategori Ekle';

  @override
  String get defaultCategories => 'Varsayılan Kategoriler';

  @override
  String get quickAddWork => 'Hızlı İş Ekle';

  @override
  String get payment => 'Ödeme';

  @override
  String get deleteClientTitle => 'Müşteri Silinsin mi?';

  @override
  String get deleteClientMessage =>
      'Bu müşteri normal listelerden kaldırılacak. İlgili işler ve dönemler geçmiş kaydı olarak korunabilir.';

  @override
  String get deleteWorkTitle => 'İş Kaydı Silinsin mi?';

  @override
  String get deleteWorkMessage => 'Bu iş aktif dönem toplamından düşülecek.';

  @override
  String get deletePeriodTitle => 'Dönem Silinsin mi?';

  @override
  String get deletePeriodMessage =>
      'Bu dönem normal listelerden kaldırılacak. Bu işlem dönem toplamlarını etkileyebilir.';

  @override
  String get select => 'Seçiniz';

  @override
  String get startDate => 'Başlangıç tarihi';

  @override
  String get endDate => 'Bitiş tarihi';

  @override
  String get minimumAmount => 'Minimum Tutar';

  @override
  String get maximumAmount => 'Maksimum Tutar';

  @override
  String get minimumQuantity => 'Minimum Adet';

  @override
  String get maximumQuantity => 'Maksimum Adet';

  @override
  String get workType => 'İş Tipi';

  @override
  String get periodStatus => 'Dönem Durumu';

  @override
  String get all => 'Hepsi';

  @override
  String get categorizedWork => 'Kategorili İş';

  @override
  String get filteredTotal => 'Filtrelenen Toplam';

  @override
  String get workCount => 'İş Sayısı';

  @override
  String get status => 'Durum';

  @override
  String get date => 'Tarih';

  @override
  String get selectClient => 'Müşteri Seç';

  @override
  String get addOneOffWork => 'Tekil İş Ekle';

  @override
  String get noCategoriesForClient =>
      'Bu müşteri için kategori yok. Tekil iş ekleyebilir veya müşteri sayfasından kategori oluşturabilirsiniz.';

  @override
  String get clientRequired => 'Lütfen müşteri seçin.';

  @override
  String get workItemAdded => 'İş kaydı eklendi.';

  @override
  String get workItemAddFailed => 'İş kaydı eklenemedi. Lütfen tekrar deneyin.';

  @override
  String get workItemDeleteFailed =>
      'İş kaydı silinemedi. Lütfen tekrar deneyin.';

  @override
  String get workStages => 'İş Aşamaları';

  @override
  String get addStage => 'Aşama Ekle';

  @override
  String get inProgress => 'Devam Ediyor';

  @override
  String get markAsCompleted => 'Tamamlandı Olarak İşaretle';

  @override
  String get receivable => 'Alınacak Tutar';

  @override
  String get notAllStagesCompleted => 'Tüm aşamalar tamamlanmadı';

  @override
  String get completeInProgressBeforeClosing =>
      'Dönemi kapatmadan önce devam eden işleri tamamlayın veya silin';

  @override
  String get createAsCompleted => 'Tamamlandı olarak oluştur';

  @override
  String get workStagesHelper =>
      'Bu aşamalar bu kategoriden oluşturulan işlere kontrol listesi olarak kopyalanır.';

  @override
  String get revisions => 'Revizyonlar';

  @override
  String get revisionHistory => 'Geçmiş';

  @override
  String get versions => 'Versiyonlar';

  @override
  String get feedback => 'Geri Bildirimler';

  @override
  String get newVersion => 'Yeni Versiyon';

  @override
  String get editVersion => 'Versiyonu Düzenle';

  @override
  String get versionLabel => 'Versiyon adı';

  @override
  String versionLabelHint(String label) {
    return 'Boş bırakırsanız $label kullanılır';
  }

  @override
  String get versionNotes => 'Neler değişti';

  @override
  String get versionLink => 'Dosya veya bağlantı';

  @override
  String get versionStatusDraft => 'Taslak';

  @override
  String get versionStatusSent => 'Gönderildi';

  @override
  String get versionStatusApproved => 'Onaylandı';

  @override
  String get deliverableNoVersions => 'Henüz versiyon yok';

  @override
  String get deliverableWaiting => 'Geri bildirim bekleniyor';

  @override
  String get deliverableChangesRequested => 'Değişiklik istendi';

  @override
  String get latestVersion => 'Güncel';

  @override
  String deletedVersionLabel(String label) {
    return '$label (silindi)';
  }

  @override
  String deleteVersionConfirm(String label) {
    return '$label silinsin mi? Bağlı geri bildirimler korunur.';
  }

  @override
  String get addFeedback => 'Geri Bildirim Ekle';

  @override
  String get editFeedback => 'Geri Bildirimi Düzenle';

  @override
  String get feedbackBody => 'Talep';

  @override
  String get feedbackKindRevision => 'Revizyon';

  @override
  String get feedbackKindNewScope => 'Yeni Kapsam';

  @override
  String get feedbackTimecode => 'Zaman kodu (isteğe bağlı)';

  @override
  String get feedbackTimecodeHint => 'örn. 00:43';

  @override
  String get feedbackVersion => 'İlgili versiyon';

  @override
  String get feedbackGeneral => 'Genel (tüm iş)';

  @override
  String get feedbackStatusOpen => 'Açık';

  @override
  String get feedbackStatusResolved => 'Çözüldü';

  @override
  String get feedbackStatusWontDo => 'Yapılmayacak';

  @override
  String get markResolved => 'Çözüldü işaretle';

  @override
  String get markWontDo => 'Yapılmayacak işaretle';

  @override
  String get reopen => 'Yeniden aç';

  @override
  String get deleteFeedbackConfirm => 'Bu geri bildirim silinsin mi?';

  @override
  String get noOpenFeedback => 'Açık geri bildirim yok.';

  @override
  String get noFeedback => 'Henüz geri bildirim yok.';

  @override
  String openRevisionCount(int count) {
    return '$count açık revizyon';
  }

  @override
  String openNewScopeCount(int count) {
    return '$count yeni kapsam talebi';
  }

  @override
  String feedbackCounts(int open, int total) {
    return '$open açık · $total toplam';
  }

  @override
  String get revisionFinancialNote =>
      'Revizyon kayıtları tutarları, ödemeleri veya iş durumunu değiştirmez.';

  @override
  String get copyLink => 'Bağlantıyı kopyala';

  @override
  String get linkCopied => 'Bağlantı kopyalandı.';

  @override
  String get revisionSaveFailed => 'Kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get workItemNotFound => 'Bu iş kaydı bulunamadı.';

  @override
  String get historyWorkItemCreated => 'İş oluşturuldu';

  @override
  String historyStepCompleted(String title) {
    return 'Aşama tamamlandı: $title';
  }

  @override
  String get historyWorkItemCompleted => 'İş tamamlandı';

  @override
  String historyVersionCreated(String label) {
    return '$label oluşturuldu';
  }

  @override
  String historyVersionSent(String label) {
    return '$label gönderildi';
  }

  @override
  String historyVersionApproved(String label) {
    return '$label onaylandı';
  }

  @override
  String get historyRevisionRequested => 'Revizyon istendi';

  @override
  String get historyNewScopeRequested => 'Yeni kapsam talebi';

  @override
  String get historyFeedbackResolved => 'Geri bildirim çözüldü';

  @override
  String get historyFeedbackWontDo =>
      'Geri bildirim yapılmayacak olarak kapatıldı';

  @override
  String get historyEmpty => 'Henüz geçmiş yok.';

  @override
  String get historyLimitationNote =>
      'Geçmiş mevcut kayıtlardan türetilir. Tekrarlanan durum değişikliklerinde yalnızca son zaman tutulur; silinen kayıtlar gösterilmez.';

  @override
  String get multiplier => 'Çarpan';

  @override
  String get validQuantityRequired => 'Geçerli bir adet girin.';

  @override
  String get workTitleRequired => 'İş başlığı boş olamaz.';

  @override
  String get workItemUpdated => 'İş kaydı güncellendi.';

  @override
  String get workItemUpdateFailed =>
      'İş kaydı güncellenemedi. Lütfen tekrar deneyin.';

  @override
  String get openRevisions => 'Açık revizyon';

  @override
  String get awaitingFeedback => 'Onay bekleyen';

  @override
  String workItemCountLabel(int count) {
    return '$count iş';
  }

  @override
  String get backupTitle => 'Yedekleme';

  @override
  String get backupDescription =>
      'Tüm verileri tek bir dosyaya kaydedin veya bir yedekten geri yükleyin. Yedeklerinizi bu bilgisayarın dışında da saklayın.';

  @override
  String get createBackup => 'Yedek al';

  @override
  String get restoreBackup => 'Yedekten geri yükle';

  @override
  String backupSaved(String path) {
    return 'Yedek kaydedildi: $path';
  }

  @override
  String get backupFailed => 'Yedek alınamadı.';

  @override
  String get restoreConfirmTitle => 'Bu yedek geri yüklensin mi?';

  @override
  String restoreConfirmMessage(int clients, int workItems) {
    return 'Yedekte $clients müşteri ve $workItems iş kaydı var. Mevcut tüm verilerin yerine geçecek. Mevcut verileriniz önce bir güvenlik kopyasına kaydedilir.';
  }

  @override
  String get restoreAction => 'Geri yükle';

  @override
  String restoreSucceeded(String path) {
    return 'Yedek geri yüklendi. Önceki veriler şuraya kaydedildi: $path';
  }

  @override
  String get restoreFailed =>
      'Yedek geri yüklenemedi. Verileriniz değiştirilmedi.';

  @override
  String get backupNotFound => 'Seçilen dosya bulunamadı.';

  @override
  String get backupInvalid => 'Bu dosya geçerli bir FlowLedger yedeği değil.';

  @override
  String get backupNewer =>
      'Bu yedek daha yeni bir FlowLedger sürümüyle alınmış. Önce uygulamayı güncelleyin.';

  @override
  String get backupCorrupted => 'Bu yedek dosyası bozuk ve geri yüklenemez.';

  @override
  String get backupFileType => 'FlowLedger yedeği';

  @override
  String get currency => 'Para birimi';

  @override
  String get currencyHelper =>
      'Yalnızca tutarların gösterimini değiştirir; kayıtlı tutarlar dönüştürülmez.';

  @override
  String get oneOffWorkTitle => 'Tek Seferlik Özel İş';

  @override
  String get workTitleRequiredShort => 'İş başlığı gereklidir.';

  @override
  String get note => 'Not';

  @override
  String get addWorkAction => 'İş Ekle';

  @override
  String get validAmountRequired => 'Geçerli bir tutar girin.';

  @override
  String get paymentReceivedTitle => 'Ödeme Aldım';

  @override
  String get closePeriodAction => 'Dönemi Kapat';

  @override
  String get amountMustBePositive => 'Tutar sıfırdan büyük olmalıdır.';

  @override
  String get amountExceedsRemaining => 'Tutar kalan ödemeden fazla olamaz.';

  @override
  String get periodOngoing => 'Devam ediyor';

  @override
  String get totalWork => 'Toplam İş';

  @override
  String get paidAmount => 'Ödenen Tutar';

  @override
  String get remainingAmountLabel => 'Kalan Tutar';

  @override
  String get workItemCountTitle => 'İş Sayısı';

  @override
  String get periodDeleteFailed => 'Dönem silinemedi. Lütfen tekrar deneyin.';

  @override
  String get periodTotal => 'Dönem Toplamı';

  @override
  String get totalWorkAmount => 'Toplam İş Tutarı';

  @override
  String get periodCategoriesTitle => 'Dönem Kategorileri';

  @override
  String get noCategorySnapshot => 'Bu dönemde kategori anlık görüntüsü yok.';

  @override
  String get worksTitle => 'İşler';

  @override
  String get noWorkInPeriod => 'Bu dönemde iş kaydı yok.';

  @override
  String get paymentRecordTitle => 'Ödeme Kaydı';

  @override
  String get noPaymentsInPeriod => 'Bu dönem için ödeme kaydı yok.';

  @override
  String get periodDetailsLoadFailed => 'Dönem ayrıntıları yüklenemedi.';

  @override
  String get openPeriodChip => 'Açık Dönem';

  @override
  String get closedPeriodTitle => 'Kapalı Dönem';

  @override
  String get periodReviewTitle => 'Dönem İncelemesi';

  @override
  String get goToClientDetail => 'Müşteri Detayına Git';

  @override
  String quantityWithUnit(String quantity) {
    return '$quantity adet';
  }

  @override
  String get clientDeleteFailed => 'Müşteri silinemedi. Lütfen tekrar deneyin.';

  @override
  String lastPayment(String date) {
    return 'Son ödeme: $date';
  }

  @override
  String get clientSaveFailed =>
      'Müşteri kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get clientNameRequired => 'Müşteri adı gereklidir.';

  @override
  String get stageUpdateFailed => 'Aşama güncellenemedi.';

  @override
  String get confirmCompleteWithOpenStages =>
      'Tüm aşamalar tamamlanmadı. Yine de işi tamamlandı olarak işaretlemek istiyor musunuz?';

  @override
  String get workCompleteFailed => 'İş tamamlanamadı.';

  @override
  String get noStagesForWork => 'Bu iş için aşama yok.';

  @override
  String stagesProgress(int done, int total) {
    return '$done/$total tamamlandı';
  }

  @override
  String exportSaved(String format) {
    return '$format çıktısı kaydedildi.';
  }

  @override
  String get exportFailed => 'Aktif dönem çıktısı kaydedilemedi.';

  @override
  String remainingPaymentHelper(String amount) {
    return 'Kalan ödeme: $amount';
  }

  @override
  String get paymentRecordedNewPeriod => 'Ödeme kaydedildi, yeni dönem açıldı.';

  @override
  String get noRemainingPayment => 'Bu dönem için kalan ödeme yok.';

  @override
  String get partialPaymentTitle => 'Kısmi Ödeme Aldım';

  @override
  String get savePartialPayment => 'Kısmi Ödemeyi Kaydet';

  @override
  String partialPaymentHelper(String amount) {
    return 'Dönem kapanmayacak. Kalan ödeme: $amount';
  }

  @override
  String get partialPaymentSaved => 'Kısmi ödeme kaydedildi.';

  @override
  String get partialPaymentFailed =>
      'Kısmi ödeme kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get partialPaymentByAmount => 'Tutar gir';

  @override
  String get partialPaymentByWork => 'İş seç';

  @override
  String get partialPaymentSelectHint =>
      'Bu ödemenin karşılığı olan tamamlanmış işleri seç.';

  @override
  String get partialPaymentNoUnpaidWork =>
      'Bu dönemde ödemesi alınmamış tamamlanmış iş yok.';

  @override
  String get partialPaymentSelectAtLeastOne => 'En az bir iş seç.';

  @override
  String get selectedWorkTotal => 'Seçilen işlerin toplamı';

  @override
  String workItemPaidOn(String date) {
    return 'Ödendi · $date';
  }

  @override
  String get paidWorkEditWarning =>
      'Bu işin ödemesi alındı olarak işaretli. Değişiklik, kayıtlı ödemeyi değiştirmez.';

  @override
  String get paidWorkDeleteWarning =>
      'Bu işin ödemesi alındı olarak işaretli. Ödeme kaydı kalır, yalnızca iş silinir.';

  @override
  String paymentCoversWork(String titles) {
    return 'Karşılığı: $titles';
  }

  @override
  String categoryWorkAdded(String name) {
    return '$name işlere eklendi.';
  }

  @override
  String get oneOffWorkAdded => 'Tek seferlik iş eklendi.';

  @override
  String get workItemDeleted => 'İş kaydı silindi.';

  @override
  String get deleteCategoryTitle => 'Kategoriyi sil';

  @override
  String deleteCategoryMessage(String name) {
    return '“$name” kategorisi silinsin mi?\n\nBu işlem geçmiş dönemleri etkilemez.';
  }

  @override
  String get categoryDeleteFailed =>
      'Kategori silinemedi. Lütfen tekrar deneyin.';

  @override
  String get noClosedPeriods => 'Henüz kapalı dönem yok.';

  @override
  String get pastPeriods => 'Geçmiş Dönemler';

  @override
  String periodStartedSummary(String date, String total, String paid) {
    return '$date tarihinde başladı · Toplam: $total · Alınan: $paid';
  }

  @override
  String get periodInfoLoading => 'Dönem bilgisi yükleniyor';

  @override
  String get exportTxt => 'TXT Al';

  @override
  String get exportXlsx => 'XLSX Al';

  @override
  String get partialPaymentButton => 'Ödemenin Bir Kısmını Aldım';

  @override
  String get pricesFixedNote =>
      'Bu listedeki fiyatlar dönem açıldığı anda sabitlenmiştir.';

  @override
  String get periodCategoriesLoadFailed => 'Dönem kategorileri yüklenemedi.';

  @override
  String get noCategoriesInPeriod => 'Bu dönem için kategori bulunmuyor.';

  @override
  String get workItemsLoadFailed => 'İş kayıtları yüklenemedi.';

  @override
  String get noWorkItemsInPeriodYet => 'Bu dönem için henüz iş kaydı yok.';

  @override
  String get thisPeriodPayments => 'Bu Dönemin Ödemeleri';

  @override
  String get paymentsLoadFailed => 'Ödeme kayıtları yüklenemedi.';

  @override
  String get defaultCategoriesNote =>
      'Bu kategoriler yeni dönemlere kopyalanır. Eski dönemlerdeki fiyatları değiştirmez.';

  @override
  String get pastPeriodsUnaffected => 'Bu işlem geçmiş dönemleri etkilemez.';

  @override
  String get noDefaultCategories => 'Henüz varsayılan kategori yok.';

  @override
  String get categorySaveFailed =>
      'Kategori kaydedilemedi. Lütfen tekrar deneyin.';

  @override
  String get categoryName => 'Kategori adı';

  @override
  String get categoryNameRequired => 'Kategori adı gereklidir.';

  @override
  String get validPriceRequired => 'Geçerli bir fiyat girin.';

  @override
  String get moveUp => 'Yukarı';

  @override
  String get moveDown => 'Aşağı';

  @override
  String get saving => 'Kaydediliyor...';

  @override
  String get reportTitle => 'FlowLedger - Aktif Dönem Raporu';

  @override
  String get reportClient => 'Müşteri';

  @override
  String get reportPeriodStart => 'Dönem başlangıcı';

  @override
  String get reportDate => 'Rapor tarihi';

  @override
  String get reportSummary => 'Özet';

  @override
  String get reportCompletedCount => 'Tamamlanan iş';

  @override
  String get reportInProgressCount => 'Devam eden iş';

  @override
  String get reportCompletedTotal => 'Tamamlanan işler toplamı';

  @override
  String get reportInProgressTotal => 'Devam eden işler toplamı';

  @override
  String get reportPaymentReceived => 'Alınan ödeme';

  @override
  String get reportRemaining => 'Kalan tutar';

  @override
  String get reportWorkItems => 'İş kayıtları';

  @override
  String get reportPayments => 'Ödemeler';

  @override
  String get reportColNo => 'Sıra';

  @override
  String get reportColDate => 'Tarih';

  @override
  String get reportColWork => 'İş';

  @override
  String get reportColStatus => 'Durum';

  @override
  String get reportColUnitPrice => 'Birim fiyat';

  @override
  String get reportColQuantity => 'Miktar';

  @override
  String get reportColMultiplier => 'Çarpan';

  @override
  String get reportColAmount => 'Tutar';

  @override
  String get reportColNotes => 'Notlar';

  @override
  String get reportColNote => 'Not';

  @override
  String reportNotePrefix(String note) {
    return 'Not: $note';
  }

  @override
  String get reportSheetName => 'Aktif Dönem';

  @override
  String get reportTextFile => 'Metin dosyası';

  @override
  String get reportExcelFile => 'Excel çalışma kitabı';

  @override
  String get reportFileSuffix => 'aktif_donem';

  @override
  String get reportUnnamedClient => 'musteri';
}
