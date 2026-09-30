import 'package:flowledger/models/work_item_version.dart';
import 'package:flowledger/repositories/revision_repository.dart';
import 'package:flowledger/repositories/work_item_repository.dart';
import 'package:flowledger/screens/client_detail_screen.dart';
import 'package:flowledger/services/database_helper.dart';
import 'package:flowledger/widgets/period_summary_strip.dart';
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

  testWidgets('deletes a work item from the client page', (tester) async {
    await setWindowSize(tester, const Size(1280, 1400));
    await tester.pumpWidget(localizedApp(
      ClientDetailScreen(clientId: fixture.clientId, clientName: 'Örnek'),
      locale: const Locale('tr'),
    ));
    await pumpIo(tester);

    await tester.tap(find.text('Thumbnail'));
    await pumpIo(tester);
    await tester.ensureVisible(find.widgetWithText(TextButton, 'Sil').first);
    await tester.tap(find.widgetWithText(TextButton, 'Sil').first);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.widgetWithText(FilledButton, 'Sil'));
    await pumpIo(tester, rounds: 15);

    final remaining = (await tester.runAsync(() =>
        WorkItemRepository(databaseHelper: helper)
            .getWorkItemsForClientOpenPeriod(fixture.clientId)))!;
    expect(find.text('İş kaydı silindi.'), findsOneWidget);
    expect(
        remaining.any((w) => w.id == fixture.openCompletedWorkItemId), isFalse);
  });

  Future<void> seedRevisions() async {
    final revisions = RevisionRepository(databaseHelper: helper);
    final a = await revisions.createVersion(fixture.openInProgressWorkItemId);
    await revisions.createFeedback(fixture.openInProgressWorkItemId,
        versionId: a.id, body: 'Yazıyı küçült');
    await revisions.createFeedback(fixture.openInProgressWorkItemId,
        body: 'Müziği kıs');
    final b = await revisions.createVersion(fixture.openCompletedWorkItemId);
    await revisions.setVersionStatus(b.id, WorkItemVersionStatus.sent);
  }

  testWidgets(
      'summary strip shows balance, open revisions and awaiting approval',
      (tester) async {
    await setWindowSize(tester, const Size(1280, 1400));
    await tester.runAsync(seedRevisions);
    await tester.pumpWidget(localizedApp(
      ClientDetailScreen(clientId: fixture.clientId, clientName: 'Örnek'),
      locale: const Locale('tr'),
    ));
    await pumpIo(tester);

    expect(find.text('Müşteriler / Örnek', findRichText: true), findsOneWidget);
    Finder metric(String label) => find.descendant(
          of: find.byType(PeriodSummaryStrip),
          matching: find.text(label),
        );
    expect(metric('Alınacak Tutar'), findsOneWidget);
    expect(metric('₺1.500,00'), findsOneWidget);
    expect(metric('Açık revizyon'), findsOneWidget);
    expect(metric('2'), findsOneWidget);
    expect(metric('Onay bekleyen'), findsOneWidget);
    expect(metric('1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('header and work list fit a narrow window', (tester) async {
    await setWindowSize(tester, const Size(420, 1600));
    await tester.runAsync(seedRevisions);
    await tester.pumpWidget(localizedApp(
      ClientDetailScreen(clientId: fixture.clientId, clientName: 'Örnek'),
      locale: const Locale('tr'),
    ));
    await pumpIo(tester);
    expect(tester.takeException(), isNull);
    expect(find.byType(PeriodSummaryStrip), findsOneWidget);
  });
}
