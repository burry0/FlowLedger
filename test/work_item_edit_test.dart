import 'package:flowledger/app/currency_controller.dart';
import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/repositories/work_item_repository.dart';
import 'package:flowledger/screens/client_detail_screen.dart';
import 'package:flowledger/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

  setUp(() async {
    testDatabase = await TestDatabase.create();
    helper = testDatabase.helper();
    DatabaseHelper.overrideInstanceForTesting(helper);
    fixture = await LedgerFixture.seed(helper);
  });
  tearDown(() async => testDatabase.dispose());

  test(
      'updates title, quantity and multiplier; total is price × quantity × multiplier',
      () async {
    final repository = WorkItemRepository(databaseHelper: helper);
    // Thumbnail: ₺750 each, quantity 2, completed.
    final updated = await repository.updateWorkItem(
      fixture.openCompletedWorkItemId,
      title: '  Thumbnail (acil) ',
      quantity: 3,
      multiplier: 1.5,
      notes: 'Hızlı teslim',
    );
    expect(updated.title, 'Thumbnail (acil)');
    expect(updated.totalPrice, 750 * 3 * 1.5);

    final reloaded =
        (await repository.getWorkItemsForClientOpenPeriod(fixture.clientId))
            .firstWhere((w) => w.id == fixture.openCompletedWorkItemId);
    expect(reloaded.multiplier, 1.5);
    expect(reloaded.quantity, 3);
    expect(reloaded.priceSnapshot, 750);
    expect(await repository.getOpenPeriodTotal(fixture.clientId), 3375);

    // An empty title keeps the current one; the multiplier can go back to 1.
    final again = await repository.updateWorkItem(
        fixture.openCompletedWorkItemId,
        title: ' ',
        quantity: 2);
    expect(again.title, 'Thumbnail (acil)');
    expect(again.totalPrice, 1500);
    await expectLater(
      repository.updateWorkItem(fixture.openCompletedWorkItemId,
          quantity: 1, multiplier: 0),
      throwsArgumentError,
    );
  });

  test('number and amount format follow language and currency', () {
    const tr =
        AppFormatter(localeName: 'tr', currency: AppCurrency('TRY', '₺'));
    const en =
        AppFormatter(localeName: 'en', currency: AppCurrency('USD', r'$'));
    const de =
        AppFormatter(localeName: 'de', currency: AppCurrency('EUR', '€'));
    expect(tr.number(2), '2');
    expect(tr.number(1.5), '1,5');
    expect(en.number(1.25), '1.25');
    expect(tr.money(3375), '₺3.375,00');
    expect(en.money(3375), r'$3,375.00');
    expect(de.money(3375), '3.375,00\u00a0€');
    expect(AppFormatter.parseNumber('1,5'), 1.5);
    expect(AppFormatter.parseNumber('1.5'), 1.5);
    expect(AppFormatter.parseNumber('1.250,75'), 1250.75);
    expect(AppFormatter.parseNumber('1,250.75'), 1250.75);
    expect(AppFormatter.parseNumber('abc'), isNull);
  });

  testWidgets('edits title, quantity and multiplier on the client page',
      (tester) async {
    await setWindowSize(tester, const Size(1280, 1400));
    await tester.pumpWidget(localizedApp(
      ClientDetailScreen(clientId: fixture.clientId, clientName: 'Örnek'),
      locale: const Locale('tr'),
    ));
    await pumpIo(tester);

    await tester.tap(find.text('Thumbnail'));
    await pumpIo(tester, rounds: 4);
    await tester.tap(find.widgetWithText(TextButton, 'Düzenle').first);
    await tester.pump(const Duration(milliseconds: 400));

    await tester.enterText(
        find.widgetWithText(TextFormField, 'İş başlığı'), 'Thumbnail seti');
    await tester.enterText(find.widgetWithText(TextFormField, 'Adet'), '3');
    await tester.pump();
    await tester.tap(find.text('×1'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('×1,5').last);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('₺750,00 × 3 × 1,5 = ₺3.375,00'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Kaydet'));
    await pumpIo(tester, rounds: 15);

    expect(find.text('İş kaydı güncellendi.'), findsOneWidget);
    expect(find.textContaining('×1,5'), findsWidgets);
    final item = (await tester.runAsync(() =>
            WorkItemRepository(databaseHelper: helper)
                .getWorkItemsForClientOpenPeriod(fixture.clientId)))!
        .firstWhere((w) => w.id == fixture.openCompletedWorkItemId);
    expect(item.title, 'Thumbnail seti');
    expect(item.totalPrice, 3375);
  });
}
