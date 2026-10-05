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
  late PaymentRepository payments;
  late WorkItemRepository workItems;
  late String openPeriodId;
  late String secondWorkItemId;

  setUp(() async {
    testDatabase = await TestDatabase.create();
    helper = testDatabase.helper();
    DatabaseHelper.overrideInstanceForTesting(helper);
    fixture = await LedgerFixture.seed(helper);
    payments = PaymentRepository(databaseHelper: helper);
    workItems = WorkItemRepository(databaseHelper: helper);
    final second = await workItems.addCustomWorkItem(
      fixture.clientId,
      'Shorts',
      400,
      0.5,
      null,
      createAsCompleted: true,
    );
    secondWorkItemId = second.id;
    final period = await PaymentPeriodRepository(databaseHelper: helper)
        .ensurePeriodCategoriesForOpenPeriod(fixture.clientId);
    openPeriodId = period.id;
  });
  tearDown(() async => testDatabase.dispose());

  group('repository', () {
    test('marks the selected work as paid by the payment', () async {
      final payment = await payments.recordPartialPaymentForOpenPeriod(
        fixture.clientId,
        1500,
        DateTime(2026, 10, 1),
        null,
        workItemIds: [fixture.openCompletedWorkItemId],
      );

      final paid = await payments.getPaidWorkForPeriod(openPeriodId);
      expect(paid.isPaid(fixture.openCompletedWorkItemId), isTrue);
      expect(paid.isPaid(secondWorkItemId), isFalse);
      expect(paid.titlesForPayment(payment.id), ['Thumbnail']);
      expect(paid.byWorkItem[fixture.openCompletedWorkItemId]!.paidAt,
          DateTime(2026, 10, 1));
    });

    test('a payment by amount marks nothing as paid', () async {
      await payments.recordPartialPaymentForOpenPeriod(
          fixture.clientId, 300, DateTime(2026, 10, 1), null);

      final paid = await payments.getPaidWorkForPeriod(openPeriodId);
      expect(paid.byWorkItem, isEmpty);
    });

    test('amount must equal the total of the selected work', () async {
      await expectLater(
        payments.recordPartialPaymentForOpenPeriod(
          fixture.clientId,
          1000,
          DateTime(2026, 10, 1),
          null,
          workItemIds: [fixture.openCompletedWorkItemId],
        ),
        throwsArgumentError,
      );
      expect(await payments.getForPeriod(openPeriodId), isEmpty);
    });

    test('in-progress and already paid work cannot be selected', () async {
      await expectLater(
        payments.recordPartialPaymentForOpenPeriod(
          fixture.clientId,
          4000,
          DateTime(2026, 10, 1),
          null,
          workItemIds: [fixture.openInProgressWorkItemId],
        ),
        throwsStateError,
      );

      await payments.recordPartialPaymentForOpenPeriod(
        fixture.clientId,
        200,
        DateTime(2026, 10, 1),
        null,
        workItemIds: [secondWorkItemId],
      );
      await expectLater(
        payments.recordPartialPaymentForOpenPeriod(
          fixture.clientId,
          200,
          DateTime(2026, 10, 2),
          null,
          workItemIds: [secondWorkItemId],
        ),
        throwsStateError,
      );
      expect(await payments.getForPeriod(openPeriodId), hasLength(1));
    });

    test('work from a closed period cannot be selected', () async {
      await expectLater(
        payments.recordPartialPaymentForOpenPeriod(
          fixture.clientId,
          4000,
          DateTime(2026, 10, 1),
          null,
          workItemIds: [fixture.closedWorkItemId],
        ),
        throwsStateError,
      );
    });

    test('deleting paid work keeps the payment and drops the paid mark',
        () async {
      final payment = await payments.recordPartialPaymentForOpenPeriod(
        fixture.clientId,
        200,
        DateTime(2026, 10, 1),
        null,
        workItemIds: [secondWorkItemId],
      );

      await workItems.softDeleteWorkItem(secondWorkItemId);

      final paid = await payments.getPaidWorkForPeriod(openPeriodId);
      expect(paid.byWorkItem, isEmpty);
      final periodPayments = await payments.getForPeriod(openPeriodId);
      expect(periodPayments.single.id, payment.id);
      expect(periodPayments.single.amount, 200);
    });

    test('paid marks stay with the period after it is closed', () async {
      await payments.recordPartialPaymentForOpenPeriod(
        fixture.clientId,
        1700,
        DateTime(2026, 10, 1),
        null,
        workItemIds: [fixture.openCompletedWorkItemId, secondWorkItemId],
      );
      await workItems.softDeleteWorkItem(fixture.openInProgressWorkItemId);
      await payments.recordPaymentAndStartNewPeriod(
          fixture.clientId, 0, DateTime(2026, 10, 3), null);

      final paid = await payments.getPaidWorkForPeriod(openPeriodId);
      expect(paid.byWorkItem.keys,
          unorderedEquals([fixture.openCompletedWorkItemId, secondWorkItemId]));
    });
  });

  group('migration', () {
    test('upgrading from version 5 keeps payments and adds the table',
        () async {
      final upgradeDatabase = await TestDatabase.create();
      addTearDown(upgradeDatabase.dispose);
      final v5 = upgradeDatabase.helper(targetVersion: 5);
      final seeded = await LedgerFixture.seed(v5);
      final before = await PaymentRepository(databaseHelper: v5)
          .getPaymentHistoryForClient(seeded.clientId);
      await v5.close();

      final current = upgradeDatabase.helper();
      final db = await current.database;
      expect(await db.getVersion(), DatabaseHelper.databaseVersion);
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE name = 'payment_allocations'");
      expect(tables, hasLength(1));
      final after = await PaymentRepository(databaseHelper: current)
          .getPaymentHistoryForClient(seeded.clientId);
      expect(after.map((p) => p.amount), before.map((p) => p.amount));
      expect(upgradeDatabase.backupFiles(), hasLength(1));
    });
  });

  testWidgets('records a partial payment by selecting work', (tester) async {
    await setWindowSize(tester, const Size(1280, 1600));
    await tester.pumpWidget(localizedApp(
      ClientDetailScreen(clientId: fixture.clientId, clientName: 'Örnek'),
      locale: const Locale('tr'),
    ));
    await pumpIo(tester);

    await tester.tap(find.text('Ödemenin Bir Kısmını Aldım'));
    await pumpIo(tester);
    await tester.tap(find.text('İş seç'));
    await tester.pump(const Duration(milliseconds: 300));

    // Only completed, unpaid work is offered.
    expect(find.widgetWithText(CheckboxListTile, 'Thumbnail'), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, 'Shorts'), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, 'Ana video kurgusu'),
        findsNothing);

    // Saving without a selection is refused.
    await tester.tap(find.text('Kısmi Ödemeyi Kaydet'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('En az bir iş seç.'), findsOneWidget);

    await tester.tap(find.widgetWithText(CheckboxListTile, 'Shorts'));
    await tester.pump(const Duration(milliseconds: 300));
    final amountField = tester.widget<TextField>(
      find.descendant(
        of: find.widgetWithText(TextFormField, 'Seçilen işlerin toplamı'),
        matching: find.byType(TextField),
      ),
    );
    expect(amountField.controller!.text, '200.00');

    await tester.tap(find.text('Kısmi Ödemeyi Kaydet'));
    // Saving reloads the page twice (local and app-wide refresh).
    await pumpIo(tester, rounds: 30);

    expect(find.text('Kısmi ödeme kaydedildi.'), findsOneWidget);
    expect(find.textContaining('Ödendi · '), findsOneWidget);
    expect(find.text('Karşılığı: Shorts'), findsOneWidget);
    final paid = (await tester
        .runAsync(() => payments.getPaidWorkForPeriod(openPeriodId)))!;
    expect(paid.byWorkItem.keys, [secondWorkItemId]);
    final recorded =
        (await tester.runAsync(() => payments.getForPeriod(openPeriodId)))!;
    expect(recorded.single.amount, 200);
  });
}
