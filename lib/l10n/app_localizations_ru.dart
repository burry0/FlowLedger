// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get dashboard => 'Обзор';

  @override
  String get clients => 'Клиенты';

  @override
  String get workItems => 'Работы';

  @override
  String get periods => 'Периоды';

  @override
  String get settings => 'Настройки';

  @override
  String get theme => 'Тема';

  @override
  String get language => 'Язык';

  @override
  String get system => 'Системная';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Тёмная';

  @override
  String get localDatabase => 'Локальная база данных';

  @override
  String get localOnlyDescription =>
      'Данные хранятся локально на этом устройстве.';

  @override
  String get cloudSyncOff => 'Облачная синхронизация в этой версии отключена.';

  @override
  String get addClient => 'Добавить клиента';

  @override
  String get oneOffWork => 'Разовая работа';

  @override
  String get recordPayment => 'Записать оплату';

  @override
  String get delete => 'Удалить';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get retry => 'Повторить';

  @override
  String get open => 'Открыть';

  @override
  String get view => 'Просмотр';

  @override
  String get filters => 'Фильтры';

  @override
  String get clearFilters => 'Сбросить фильтры';

  @override
  String get client => 'Клиент';

  @override
  String get category => 'Категория';

  @override
  String get allClients => 'Все клиенты';

  @override
  String get allCategories => 'Все категории';

  @override
  String get amount => 'Сумма';

  @override
  String get quantity => 'Количество';

  @override
  String get notes => 'Заметки';

  @override
  String get paymentDate => 'Дата оплаты';

  @override
  String get activePeriod => 'Активный период';

  @override
  String get closedPeriod => 'Закрытый период';

  @override
  String get readOnly => 'Только чтение';

  @override
  String get periodCategories => 'Категории периода';

  @override
  String get completed => 'Завершено';

  @override
  String get edit => 'Изменить';

  @override
  String get totalOpenReceivable => 'Всего к получению';

  @override
  String get activeClients => 'Активные клиенты';

  @override
  String get workCompletedThisMonth => 'Завершено в этом месяце';

  @override
  String get paymentsReceivedThisMonth => 'Получено в этом месяце';

  @override
  String get clientsWithBalances => 'Клиенты с задолженностью';

  @override
  String get noClientBalances => 'Ни у одного клиента нет задолженности.';

  @override
  String get noClients => 'Клиенты не найдены';

  @override
  String get addFirstClient =>
      'Добавьте первого клиента, чтобы начать учёт работ.';

  @override
  String get noWorkItems => 'Работ пока нет.';

  @override
  String get noPeriods => 'Нет периодов для отображения.';

  @override
  String get clientName => 'Имя клиента';

  @override
  String get workTitle => 'Название работы';

  @override
  String get price => 'Цена';

  @override
  String get add => 'Добавить';

  @override
  String get editWorkItem => 'Изменить работу';

  @override
  String get editCategory => 'Изменить категорию';

  @override
  String get addCategory => 'Добавить категорию';

  @override
  String get defaultCategories => 'Категории по умолчанию';

  @override
  String get quickAddWork => 'Быстро добавить работу';

  @override
  String get payment => 'Оплата';

  @override
  String get deleteClientTitle => 'Удалить клиента?';

  @override
  String get deleteClientMessage =>
      'Клиент будет убран из обычных списков. Связанные работы и периоды могут остаться в истории.';

  @override
  String get deleteWorkTitle => 'Удалить работу?';

  @override
  String get deleteWorkMessage =>
      'Работа будет исключена из итога активного периода.';

  @override
  String get deletePeriodTitle => 'Удалить период?';

  @override
  String get deletePeriodMessage =>
      'Период будет убран из обычных списков. Это может повлиять на итоги периодов.';

  @override
  String get select => 'Выбрать';

  @override
  String get startDate => 'Дата начала';

  @override
  String get endDate => 'Дата окончания';

  @override
  String get minimumAmount => 'Минимальная сумма';

  @override
  String get maximumAmount => 'Максимальная сумма';

  @override
  String get minimumQuantity => 'Минимальное количество';

  @override
  String get maximumQuantity => 'Максимальное количество';

  @override
  String get workType => 'Тип работы';

  @override
  String get periodStatus => 'Статус периода';

  @override
  String get all => 'Все';

  @override
  String get categorizedWork => 'Работы по категориям';

  @override
  String get filteredTotal => 'Итого по фильтру';

  @override
  String get workCount => 'Количество работ';

  @override
  String get status => 'Статус';

  @override
  String get date => 'Дата';

  @override
  String get selectClient => 'Выбрать клиента';

  @override
  String get addOneOffWork => 'Добавить разовую работу';

  @override
  String get noCategoriesForClient =>
      'У этого клиента нет категорий. Можно добавить разовую работу или создать категорию на странице клиента.';

  @override
  String get clientRequired => 'Выберите клиента.';

  @override
  String get workItemAdded => 'Работа добавлена.';

  @override
  String get workItemAddFailed =>
      'Не удалось добавить работу. Попробуйте ещё раз.';

  @override
  String get workItemDeleteFailed =>
      'Не удалось удалить работу. Попробуйте ещё раз.';

  @override
  String get workStages => 'Этапы работы';

  @override
  String get addStage => 'Добавить этап';

  @override
  String get inProgress => 'В работе';

  @override
  String get markAsCompleted => 'Отметить как завершённую';

  @override
  String get receivable => 'К получению';

  @override
  String get notAllStagesCompleted => 'Не все этапы завершены';

  @override
  String get completeInProgressBeforeClosing =>
      'Завершите или удалите работы в процессе, прежде чем закрыть период';

  @override
  String get createAsCompleted => 'Создать как завершённую';

  @override
  String get workStagesHelper =>
      'Эти этапы копируются как чек-лист в работы, созданные из этой категории.';

  @override
  String get revisions => 'Правки';

  @override
  String get revisionHistory => 'История';

  @override
  String get versions => 'Версии';

  @override
  String get feedback => 'Отзывы';

  @override
  String get newVersion => 'Новая версия';

  @override
  String get editVersion => 'Изменить версию';

  @override
  String get versionLabel => 'Название версии';

  @override
  String versionLabelHint(String label) {
    return 'Оставьте пустым, чтобы использовать $label';
  }

  @override
  String get versionNotes => 'Что изменилось';

  @override
  String get versionLink => 'Файл или ссылка';

  @override
  String get versionStatusDraft => 'Черновик';

  @override
  String get versionStatusSent => 'Отправлено';

  @override
  String get versionStatusApproved => 'Утверждено';

  @override
  String get deliverableNoVersions => 'Версий пока нет';

  @override
  String get deliverableWaiting => 'Ожидает отзыва';

  @override
  String get deliverableChangesRequested => 'Запрошены изменения';

  @override
  String get latestVersion => 'Текущая';

  @override
  String deletedVersionLabel(String label) {
    return '$label (удалена)';
  }

  @override
  String deleteVersionConfirm(String label) {
    return 'Удалить $label? Связанные отзывы сохранятся.';
  }

  @override
  String get addFeedback => 'Добавить отзыв';

  @override
  String get editFeedback => 'Изменить отзыв';

  @override
  String get feedbackBody => 'Запрос';

  @override
  String get feedbackKindRevision => 'Правка';

  @override
  String get feedbackKindNewScope => 'Новый объём';

  @override
  String get feedbackTimecode => 'Таймкод (необязательно)';

  @override
  String get feedbackTimecodeHint => 'напр. 00:43';

  @override
  String get feedbackVersion => 'Связанная версия';

  @override
  String get feedbackGeneral => 'Общий (вся работа)';

  @override
  String get feedbackStatusOpen => 'Открыт';

  @override
  String get feedbackStatusResolved => 'Решён';

  @override
  String get feedbackStatusWontDo => 'Не будет сделано';

  @override
  String get markResolved => 'Отметить как решённый';

  @override
  String get markWontDo => 'Отметить «не будет сделано»';

  @override
  String get reopen => 'Открыть снова';

  @override
  String get deleteFeedbackConfirm => 'Удалить этот отзыв?';

  @override
  String get noOpenFeedback => 'Открытых отзывов нет.';

  @override
  String get noFeedback => 'Отзывов пока нет.';

  @override
  String openRevisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count открытой правки',
      many: '$count открытых правок',
      few: '$count открытые правки',
      one: '$count открытая правка',
    );
    return '$_temp0';
  }

  @override
  String openNewScopeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count запроса нового объёма',
      many: '$count запросов нового объёма',
      few: '$count запроса нового объёма',
      one: '$count запрос нового объёма',
    );
    return '$_temp0';
  }

  @override
  String feedbackCounts(int open, int total) {
    return 'открыто $open · всего $total';
  }

  @override
  String get revisionFinancialNote =>
      'Записи о правках не меняют суммы, оплаты и статус работы.';

  @override
  String get copyLink => 'Копировать ссылку';

  @override
  String get linkCopied => 'Ссылка скопирована.';

  @override
  String get revisionSaveFailed => 'Не удалось сохранить. Попробуйте ещё раз.';

  @override
  String get workItemNotFound => 'Работа не найдена.';

  @override
  String get historyWorkItemCreated => 'Работа создана';

  @override
  String historyStepCompleted(String title) {
    return 'Этап завершён: $title';
  }

  @override
  String get historyWorkItemCompleted => 'Работа завершена';

  @override
  String historyVersionCreated(String label) {
    return '$label создана';
  }

  @override
  String historyVersionSent(String label) {
    return '$label отправлена';
  }

  @override
  String historyVersionApproved(String label) {
    return '$label утверждена';
  }

  @override
  String get historyRevisionRequested => 'Запрошена правка';

  @override
  String get historyNewScopeRequested => 'Запрошен новый объём';

  @override
  String get historyFeedbackResolved => 'Отзыв решён';

  @override
  String get historyFeedbackWontDo => 'Отзыв закрыт: не будет сделано';

  @override
  String get historyEmpty => 'Истории пока нет.';

  @override
  String get historyLimitationNote =>
      'История строится по текущим записям. При повторной смене статуса сохраняется только последнее время; удалённые записи не показываются.';

  @override
  String get multiplier => 'Множитель';

  @override
  String get validQuantityRequired => 'Введите корректное количество.';

  @override
  String get workTitleRequired => 'Укажите название работы.';

  @override
  String get workItemUpdated => 'Работа обновлена.';

  @override
  String get workItemUpdateFailed =>
      'Не удалось обновить работу. Попробуйте ещё раз.';

  @override
  String get openRevisions => 'Открытые правки';

  @override
  String get awaitingFeedback => 'Ожидает отзыва';

  @override
  String workItemCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count работы',
      many: '$count работ',
      few: '$count работы',
      one: '$count работа',
    );
    return '$_temp0';
  }

  @override
  String get backupTitle => 'Резервная копия';

  @override
  String get backupDescription =>
      'Сохраните все данные в один файл или восстановите их из копии. Храните копии и вне этого компьютера.';

  @override
  String get createBackup => 'Создать копию';

  @override
  String get restoreBackup => 'Восстановить из копии';

  @override
  String backupSaved(String path) {
    return 'Копия сохранена: $path';
  }

  @override
  String get backupFailed => 'Не удалось создать резервную копию.';

  @override
  String get restoreConfirmTitle => 'Восстановить эту копию?';

  @override
  String restoreConfirmMessage(int clients, int workItems) {
    return 'В копии: клиентов — $clients, работ — $workItems. Она заменит все текущие данные. Сначала текущие данные будут сохранены в страховочную копию.';
  }

  @override
  String get restoreAction => 'Восстановить';

  @override
  String restoreSucceeded(String path) {
    return 'Копия восстановлена. Прежние данные сохранены в: $path';
  }

  @override
  String get restoreFailed =>
      'Не удалось восстановить копию. Ваши данные не изменены.';

  @override
  String get backupNotFound => 'Выбранный файл не найден.';

  @override
  String get backupInvalid =>
      'Этот файл не является резервной копией FlowLedger.';

  @override
  String get backupNewer =>
      'Эта копия создана более новой версией FlowLedger. Сначала обновите приложение.';

  @override
  String get backupCorrupted =>
      'Файл копии повреждён и не может быть восстановлен.';

  @override
  String get backupFileType => 'Резервная копия FlowLedger';

  @override
  String get currency => 'Валюта';

  @override
  String get currencyHelper =>
      'Меняет только отображение сумм; сохранённые суммы не пересчитываются.';

  @override
  String get oneOffWorkTitle => 'Разовая работа';

  @override
  String get workTitleRequiredShort => 'Укажите название работы.';

  @override
  String get note => 'Заметка';

  @override
  String get addWorkAction => 'Добавить работу';

  @override
  String get validAmountRequired => 'Введите корректную сумму.';

  @override
  String get paymentReceivedTitle => 'Оплата получена';

  @override
  String get closePeriodAction => 'Закрыть период';

  @override
  String get amountMustBePositive => 'Сумма должна быть больше нуля.';

  @override
  String get amountExceedsRemaining => 'Сумма не может превышать остаток.';

  @override
  String get periodOngoing => 'Продолжается';

  @override
  String get totalWork => 'Всего работ';

  @override
  String get paidAmount => 'Оплачено';

  @override
  String get remainingAmountLabel => 'Остаток';

  @override
  String get workItemCountTitle => 'Количество работ';

  @override
  String get periodDeleteFailed =>
      'Не удалось удалить период. Попробуйте ещё раз.';

  @override
  String get periodTotal => 'Итого за период';

  @override
  String get totalWorkAmount => 'Сумма работ';

  @override
  String get periodCategoriesTitle => 'Категории периода';

  @override
  String get noCategorySnapshot => 'В этом периоде нет снимка категорий.';

  @override
  String get worksTitle => 'Работы';

  @override
  String get noWorkInPeriod => 'В этом периоде нет работ.';

  @override
  String get paymentRecordTitle => 'Оплаты';

  @override
  String get noPaymentsInPeriod => 'За этот период оплат нет.';

  @override
  String get periodDetailsLoadFailed => 'Не удалось загрузить данные периода.';

  @override
  String get openPeriodChip => 'Открытый период';

  @override
  String get closedPeriodTitle => 'Закрытый период';

  @override
  String get periodReviewTitle => 'Обзор периода';

  @override
  String get goToClientDetail => 'К клиенту';

  @override
  String quantityWithUnit(String quantity) {
    return '$quantity шт.';
  }

  @override
  String get clientDeleteFailed =>
      'Не удалось удалить клиента. Попробуйте ещё раз.';

  @override
  String lastPayment(String date) {
    return 'Последняя оплата: $date';
  }

  @override
  String get clientSaveFailed =>
      'Не удалось сохранить клиента. Попробуйте ещё раз.';

  @override
  String get clientNameRequired => 'Укажите имя клиента.';

  @override
  String get stageUpdateFailed => 'Не удалось обновить этап.';

  @override
  String get confirmCompleteWithOpenStages =>
      'Не все этапы завершены. Всё равно отметить работу как завершённую?';

  @override
  String get workCompleteFailed => 'Не удалось завершить работу.';

  @override
  String get noStagesForWork => 'У этой работы нет этапов.';

  @override
  String stagesProgress(int done, int total) {
    return 'завершено $done/$total';
  }

  @override
  String exportSaved(String format) {
    return 'Экспорт $format сохранён.';
  }

  @override
  String get exportFailed => 'Не удалось сохранить экспорт активного периода.';

  @override
  String remainingPaymentHelper(String amount) {
    return 'Остаток: $amount';
  }

  @override
  String get paymentRecordedNewPeriod =>
      'Оплата записана, открыт новый период.';

  @override
  String get noRemainingPayment => 'За этот период нет остатка к оплате.';

  @override
  String get partialPaymentTitle => 'Получена частичная оплата';

  @override
  String get savePartialPayment => 'Сохранить частичную оплату';

  @override
  String partialPaymentHelper(String amount) {
    return 'Период останется открытым. Остаток: $amount';
  }

  @override
  String get partialPaymentSaved => 'Частичная оплата записана.';

  @override
  String get partialPaymentFailed =>
      'Не удалось записать частичную оплату. Попробуйте ещё раз.';

  @override
  String categoryWorkAdded(String name) {
    return '«$name» добавлена в работы.';
  }

  @override
  String get oneOffWorkAdded => 'Разовая работа добавлена.';

  @override
  String get workItemDeleted => 'Работа удалена.';

  @override
  String get deleteCategoryTitle => 'Удалить категорию';

  @override
  String deleteCategoryMessage(String name) {
    return 'Удалить категорию «$name»?\n\nПрошлые периоды это не затронет.';
  }

  @override
  String get categoryDeleteFailed =>
      'Не удалось удалить категорию. Попробуйте ещё раз.';

  @override
  String get noClosedPeriods => 'Закрытых периодов пока нет.';

  @override
  String get pastPeriods => 'Прошлые периоды';

  @override
  String periodStartedSummary(String date, String total, String paid) {
    return 'Начат $date · Итого: $total · Получено: $paid';
  }

  @override
  String get periodInfoLoading => 'Загрузка данных периода';

  @override
  String get exportTxt => 'Экспорт TXT';

  @override
  String get exportXlsx => 'Экспорт XLSX';

  @override
  String get partialPaymentButton => 'Записать частичную оплату';

  @override
  String get pricesFixedNote =>
      'Цены в этом списке зафиксированы при открытии периода.';

  @override
  String get periodCategoriesLoadFailed =>
      'Не удалось загрузить категории периода.';

  @override
  String get noCategoriesInPeriod => 'Для этого периода нет категорий.';

  @override
  String get workItemsLoadFailed => 'Не удалось загрузить работы.';

  @override
  String get noWorkItemsInPeriodYet => 'В этом периоде пока нет работ.';

  @override
  String get thisPeriodPayments => 'Оплаты за период';

  @override
  String get paymentsLoadFailed => 'Не удалось загрузить оплаты.';

  @override
  String get defaultCategoriesNote =>
      'Эти категории копируются в новые периоды. Цены в прошлых периодах не меняются.';

  @override
  String get pastPeriodsUnaffected => 'Прошлые периоды это не затронет.';

  @override
  String get noDefaultCategories => 'Категорий по умолчанию пока нет.';

  @override
  String get categorySaveFailed =>
      'Не удалось сохранить категорию. Попробуйте ещё раз.';

  @override
  String get categoryName => 'Название категории';

  @override
  String get categoryNameRequired => 'Укажите название категории.';

  @override
  String get validPriceRequired => 'Введите корректную цену.';

  @override
  String get moveUp => 'Вверх';

  @override
  String get moveDown => 'Вниз';

  @override
  String get saving => 'Сохранение…';

  @override
  String get reportTitle => 'FlowLedger — отчёт за активный период';

  @override
  String get reportClient => 'Клиент';

  @override
  String get reportPeriodStart => 'Начало периода';

  @override
  String get reportDate => 'Дата отчёта';

  @override
  String get reportSummary => 'Сводка';

  @override
  String get reportCompletedCount => 'Завершённые работы';

  @override
  String get reportInProgressCount => 'Работы в процессе';

  @override
  String get reportCompletedTotal => 'Сумма завершённых работ';

  @override
  String get reportInProgressTotal => 'Сумма работ в процессе';

  @override
  String get reportPaymentReceived => 'Получено оплат';

  @override
  String get reportRemaining => 'Остаток';

  @override
  String get reportWorkItems => 'Работы';

  @override
  String get reportPayments => 'Оплаты';

  @override
  String get reportColNo => '№';

  @override
  String get reportColDate => 'Дата';

  @override
  String get reportColWork => 'Работа';

  @override
  String get reportColStatus => 'Статус';

  @override
  String get reportColUnitPrice => 'Цена за единицу';

  @override
  String get reportColQuantity => 'Кол-во';

  @override
  String get reportColMultiplier => 'Множитель';

  @override
  String get reportColAmount => 'Сумма';

  @override
  String get reportColNotes => 'Заметки';

  @override
  String get reportColNote => 'Заметка';

  @override
  String reportNotePrefix(String note) {
    return 'Заметка: $note';
  }

  @override
  String get reportSheetName => 'Активный период';

  @override
  String get reportTextFile => 'Текстовый файл';

  @override
  String get reportExcelFile => 'Книга Excel';

  @override
  String get reportFileSuffix => 'aktivnyi_period';

  @override
  String get reportUnnamedClient => 'klient';
}
