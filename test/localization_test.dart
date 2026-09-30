import 'package:flowledger/app/currency_controller.dart';
import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/app_localizations.dart';
import 'package:flowledger/repositories/revision_repository.dart';
import 'package:flowledger/screens/client_detail_screen.dart';
import 'package:flowledger/screens/work_item_revisions_screen.dart';
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
  test('four languages are supported', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
      {'tr', 'en', 'de', 'ru'},
    );
  });

  test('Russian plural forms', () {
    final ru = lookupAppLocalizations(const Locale('ru'));
    expect(ru.openRevisionCount(1), '1 открытая правка');
    expect(ru.openRevisionCount(3), '3 открытые правки');
    expect(ru.openRevisionCount(5), '5 открытых правок');
    expect(ru.workItemCountLabel(21), '21 работа');
  });

  group('screens in every language', () {
    late TestDatabase testDatabase;
    late DatabaseHelper helper;
    late LedgerFixture fixture;

    setUp(() async {
      testDatabase = await TestDatabase.create();
      helper = testDatabase.helper();
      DatabaseHelper.overrideInstanceForTesting(helper);
      fixture = await LedgerFixture.seed(helper);
      final revisions = RevisionRepository(databaseHelper: helper);
      final v = await revisions.createVersion(fixture.openInProgressWorkItemId);
      await revisions.createFeedback(fixture.openInProgressWorkItemId,
          versionId: v.id, body: 'Yazıyı küçült', timecode: '00:43');
    });
    tearDown(() async => testDatabase.dispose());

    for (final code in ['tr', 'en', 'de', 'ru']) {
      for (final width in [420.0, 1280.0]) {
        testWidgets('client page and revisions: $code, ${width.toInt()}px',
            (tester) async {
          await setWindowSize(tester, Size(width, 1600));
          await tester.pumpWidget(localizedApp(
            ClientDetailScreen(clientId: fixture.clientId, clientName: 'Örnek'),
            locale: Locale(code),
          ));
          await pumpIo(tester);
          expect(tester.takeException(), isNull);

          await tester.pumpWidget(localizedApp(
            WorkItemRevisionsScreen(
              workItemId: fixture.openInProgressWorkItemId,
              title: 'Ana video kurgusu',
              repository: RevisionRepository(databaseHelper: helper),
            ),
            locale: Locale(code),
          ));
          await pumpIo(tester);
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('amounts reformat when the currency changes', (tester) async {
      final currency = CurrencyController();
      await setWindowSize(tester, const Size(1280, 1600));
      await tester.pumpWidget(CurrencyScope(
        controller: currency,
        child: localizedApp(
          ClientDetailScreen(clientId: fixture.clientId, clientName: 'Örnek'),
          locale: const Locale('en'),
        ),
      ));
      await pumpIo(tester);
      expect(find.text('₺1,500.00'), findsWidgets);

      // Only the display changes; the settings store is not called.
      await tester
          .runAsync(() => currency.setCurrency('USD').catchError((_) {}));
      await tester.pump();
      expect(find.text(r'$1,500.00'), findsWidgets);
      expect(find.text('₺1,500.00'), findsNothing);
      await pumpIo(tester, rounds: 3);
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
