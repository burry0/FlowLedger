import 'package:flowledger/l10n/app_localizations.dart';
import 'package:flowledger/repositories/payment_period_repository.dart';
import 'package:flowledger/repositories/payment_repository.dart';
import 'package:flowledger/repositories/work_item_repository.dart';
import 'package:flowledger/screens/client_detail_screen.dart';
import 'package:flowledger/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/ledger_fixture.dart';
import 'support/test_database.dart';
import 'support/widget_harness.dart';

Future<void> pumpIo(WidgetTester tester, {int rounds = 10}) async {
  for (var i = 0; i < rounds; i++) {
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 40)));
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late TestDatabase testDatabase;
  late DatabaseHelper helper;
  late LedgerFixture fixture;
  late WorkItemRepository workItems;
  late PaymentRepository payments;

  setUp(() async {
    testDatabase = await TestDatabase.create();
    helper = testDatabase.helper();
    DatabaseHelper.overrideInstanceForTesting(helper);
    fixture = await LedgerFixture.seed(helper);
    workItems = WorkItemRepository(databaseHelper: helper);
    payments = PaymentRepository(databaseHelper: helper);
  });
  tearDown(() async => testDatabase.dispose());

  Future<String> openPeriodId() async =>
      (await PaymentPeriodRepository(databaseHelper: helper)
              .ensurePeriodCategoriesForOpenPeriod(fixture.clientId))
          .id;

  Future<void> closeOpenPeriod() async {
    await workItems.softDeleteWorkItem(fixture.openInProgressWorkItemId);
    await payments.recordPaymentAndStartNewPeriod(
        fixture.clientId, 0, DateTime(2026, 10, 1), null);
  }

  group('repository', () {
    test('a draft bills its share and waits for completion', () async {
      final draft = await workItems.addCustomWorkItem(
        fixture.clientId,
        'Belgesel',
        1000,
        2,
        null,
        createAsCompleted: true,
        draftShare: 0.4,
      );

      expect(draft.totalPrice, 800);
      final stored =
          (await workItems.getWorkItemsForClientOpenPeriod(fixture.clientId))
              .firstWhere((w) => w.id == draft.id);
      expect(stored.isDraft, isTrue);
      expect(stored.billedShare, 0.4);
      expect(stored.totalPrice, 800);

      final pending = await workItems.getPendingCompletions(fixture.clientId);
      expect(pending.single.draft.id, draft.id);
      expect(pending.single.remainingAmount, closeTo(1200, 0.001));
    });

    test('completing a draft from a closed period bills the rest', () async {
      final draft = await workItems.addCustomWorkItem(
        fixture.clientId,
        'Belgesel',
        1000,
        1,
        null,
        createAsCompleted: true,
        draftShare: 0.5,
      );
      await closeOpenPeriod();

      final completion = await workItems.completeDraft(draft.id);

      expect(completion.paymentPeriodId, await openPeriodId());
      expect(completion.completesWorkItemId, draft.id);
      expect(completion.billedShare, 0.5);
      expect(completion.totalPrice, 500);
      expect(completion.priceSnapshot, 1000);
      expect(await workItems.getPendingCompletions(fixture.clientId), isEmpty);
      final open =
          await workItems.getWorkItemsForClientOpenPeriod(fixture.clientId);
      final storedCompletion = open.singleWhere((w) => w.id == completion.id);
      expect(storedCompletion.isCompletion, isTrue);
      expect(storedCompletion.totalPrice, 500);
      expect(await workItems.getOpenPeriodTotal(fixture.clientId), 500);

      await expectLater(workItems.completeDraft(draft.id), throwsStateError);
    });

    test('the completion uses the draft price, not the current one', () async {
      final categories = await PaymentPeriodRepository(databaseHelper: helper)
          .getOpenPeriodCategoriesForClient(fixture.clientId);
      final categoryWork =
          await workItems.addWorkItemFromPeriodCategory(categories.single.id);
      await workItems.updateWorkItem(categoryWork.id,
          quantity: 1, multiplier: 1.5, isDraft: true, draftShare: 0.3);
      await workItems.markWorkItemCompleted(categoryWork.id);

      final completion = await workItems.completeDraft(categoryWork.id);

      // 4000 × 1.5 = 6000 in full; 30% now, 70% on completion.
      expect(completion.totalPrice, closeTo(4200, 0.001));
      expect(completion.multiplier, 1.5);
    });

    test('editing turns the draft mark on and off', () async {
      final item = await workItems.updateWorkItem(
        fixture.openCompletedWorkItemId,
        quantity: 2,
        isDraft: true,
        draftShare: 0.25,
      );
      expect(item.totalPrice, 375);
      expect(item.isDraft, isTrue);

      final changed = await workItems.updateWorkItem(
        fixture.openCompletedWorkItemId,
        quantity: 2,
        isDraft: true,
        draftShare: 0.6,
      );
      expect(changed.totalPrice, 900);

      final normal = await workItems.updateWorkItem(
        fixture.openCompletedWorkItemId,
        quantity: 2,
        isDraft: false,
      );
      expect(normal.totalPrice, 1500);
      expect(normal.isDraft, isFalse);
      expect(await workItems.getPendingCompletions(fixture.clientId), isEmpty);
    });

    test('a completed draft and its completion keep their shares', () async {
      await workItems.updateWorkItem(fixture.openCompletedWorkItemId,
          quantity: 2, isDraft: true, draftShare: 0.5);
      final completion =
          await workItems.completeDraft(fixture.openCompletedWorkItemId);

      await expectLater(
        workItems.updateWorkItem(fixture.openCompletedWorkItemId,
            quantity: 2, isDraft: true, draftShare: 0.8),
        throwsStateError,
      );
      await expectLater(
        workItems.updateWorkItem(completion.id,
            quantity: 2, isDraft: true, draftShare: 0.5),
        throwsStateError,
      );

      // Other changes still work and keep the share.
      final edited = await workItems.updateWorkItem(completion.id,
          title: 'Thumbnail final', quantity: 4);
      expect(edited.billedShare, 0.5);
      expect(edited.totalPrice, 1500);
      final draft = await workItems.updateWorkItem(
          fixture.openCompletedWorkItemId,
          quantity: 2,
          isDraft: true,
          draftShare: 0.5);
      expect(draft.totalPrice, 750);
    });

    test('deleting the completion makes the draft pending again', () async {
      await workItems.updateWorkItem(fixture.openCompletedWorkItemId,
          quantity: 2, isDraft: true, draftShare: 0.5);
      final completion =
          await workItems.completeDraft(fixture.openCompletedWorkItemId);

      await workItems.softDeleteWorkItem(completion.id);

      final pending = await workItems.getPendingCompletions(fixture.clientId);
      expect(pending.single.draft.id, fixture.openCompletedWorkItemId);
    });

    test('invalid shares are rejected', () async {
      for (final share in [0.0, 1.0, 1.2]) {
        await expectLater(
          workItems.addCustomWorkItem(fixture.clientId, 'X', 100, 1, null,
              draftShare: share),
          throwsArgumentError,
        );
      }
    });
  });

  test('upgrading from version 6 keeps totals and bills existing work in full',
      () async {
    final upgradeDatabase = await TestDatabase.create();
    addTearDown(upgradeDatabase.dispose);
    final v6 = upgradeDatabase.helper(targetVersion: 6);
    final seeded = await LedgerFixture.seed(v6);
    final before = await WorkItemRepository(databaseHelper: v6)
        .getWorkItemsForClientOpenPeriod(seeded.clientId);
    await v6.close();

    final current = upgradeDatabase.helper();
    final db = await current.database;
    expect(await db.getVersion(), DatabaseHelper.databaseVersion);
    final after = await WorkItemRepository(databaseHelper: current)
        .getWorkItemsForClientOpenPeriod(seeded.clientId);
    expect(after.map((w) => w.totalPrice), before.map((w) => w.totalPrice));
    expect(after.every((w) => w.billedShare == 1 && !w.isDraft), isTrue);
    expect(upgradeDatabase.backupFiles(), hasLength(1));
  });

  testWidgets('adds a draft with the slider and completes it later',
      (tester) async {
    await setWindowSize(tester, const Size(1280, 2000));
    await tester.pumpWidget(localizedApp(
      ClientDetailScreen(clientId: fixture.clientId, clientName: 'Örnek'),
      locale: const Locale('tr'),
    ));
    await pumpIo(tester);

    await tester.tap(find.text('+ Tek Seferlik İş'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(
        find.widgetWithText(TextFormField, 'İş başlığı'), 'Belgesel');
    await tester.enterText(find.widgetWithText(TextFormField, 'Fiyat'), '2000');
    await tester.pump();
    await tester.tap(find.text('Taslak — devamı sonra gelecek'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Şimdi ₺1.000,00 (%50) · Tamamlanınca ₺1.000,00'),
        findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'İş Ekle'));
    await pumpIo(tester, rounds: 30);

    expect(find.textContaining('Taslak %50'), findsOneWidget);
    expect(find.text('Tamamlanacak Taslaklar'), findsOneWidget);
    expect(find.text('1 taslak · faturalanacak ₺1.000,00'), findsOneWidget);
    // The list itself is not on the page, only in the dialog.
    expect(find.widgetWithText(FilledButton, 'Tamamla'), findsNothing);

    await tester.tap(find.text('Taslakları görüntüle'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.widgetWithText(FilledButton, 'Tamamla'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(
        find.textContaining('“Belgesel” için kalan ₺1.000,00'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Tamamla').last);
    await pumpIo(tester, rounds: 30);

    // The last draft was completed, so the dialog closed by itself.
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Tamamlama aktif döneme eklendi.'), findsOneWidget);
    expect(find.text('Tamamlanacak Taslaklar'), findsNothing);
    expect(find.textContaining('Tamamlama %50'), findsOneWidget);
    final open = (await tester.runAsync(
        () => workItems.getWorkItemsForClientOpenPeriod(fixture.clientId)))!;
    expect(open.where((w) => w.title == 'Belgesel').map((w) => w.totalPrice),
        unorderedEquals([1000, 1000]));
  });

  for (final code in ['tr', 'en', 'de', 'ru']) {
    testWidgets('many drafts stay compact on a narrow window: $code',
        (tester) async {
      await setWindowSize(tester, const Size(420, 900));
      await tester.runAsync(() async {
        for (var i = 1; i <= 13; i++) {
          await workItems.addCustomWorkItem(
            fixture.clientId,
            'Uzun başlıklı belgesel taslağı bölüm $i',
            123456,
            1,
            null,
            createAsCompleted: true,
            draftShare: 0.35,
          );
        }
      });
      await tester.pumpWidget(localizedApp(
        ClientDetailScreen(clientId: fixture.clientId, clientName: 'Örnek'),
        locale: Locale(code),
      ));
      await pumpIo(tester);

      // One summary row on the page instead of 13 rows.
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.byIcon(Icons.hourglass_bottom_outlined),
        300,
        scrollable: find
            .byWidgetPredicate((widget) =>
                widget is Scrollable &&
                widget.axisDirection == AxisDirection.down)
            .first,
      );
      expect(find.byIcon(Icons.hourglass_bottom_outlined), findsOneWidget);
      expect(find.textContaining('13'), findsWidgets);

      final open = find.descendant(
        of: find.ancestor(
          of: find.byIcon(Icons.hourglass_bottom_outlined),
          matching: find.byType(Card),
        ),
        matching: find.byType(OutlinedButton),
      );
      await tester.ensureVisible(open);
      await tester.pump();
      await tester.tap(open);
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull);
      expect(find.byType(AlertDialog), findsOneWidget);
      // The dialog list scrolls instead of growing past the window.
      expect(
        tester.getSize(find.byType(AlertDialog)).height,
        lessThanOrEqualTo(900),
      );

      await tester.tap(find.widgetWithText(TextButton, lookupClose(code)));
      await pumpIo(tester);
      expect(find.byType(AlertDialog), findsNothing);
    });
  }
}

String lookupClose(String code) => lookupAppLocalizations(Locale(code)).close;
