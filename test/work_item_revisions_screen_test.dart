import 'package:flowledger/models/work_item_version.dart';
import 'package:flowledger/repositories/revision_repository.dart';
import 'package:flowledger/screens/work_item_revisions_screen.dart';
import 'package:flowledger/services/database_helper.dart';
import 'package:flowledger/widgets/revisions/feedback_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ledger_fixture.dart';
import 'support/test_database.dart';
import 'support/widget_harness.dart';

/// Searches feedback rows only; the same text can appear in the history.
Finder inFeedbackList(Finder finder) =>
    find.descendant(of: find.byType(FeedbackTile), matching: finder);

void main() {
  late TestDatabase testDatabase;
  late DatabaseHelper helper;
  late RevisionRepository repository;
  late LedgerFixture fixture;

  setUp(() async {
    testDatabase = await TestDatabase.create();
    helper = testDatabase.helper();
    fixture = await LedgerFixture.seed(helper);
    repository = RevisionRepository(databaseHelper: helper);
  });
  tearDown(() async => testDatabase.dispose());

  Widget screen({Locale locale = const Locale('en')}) => localizedApp(
        WorkItemRevisionsScreen(
          workItemId: fixture.closedWorkItemId,
          title: 'Ana video kurgusu',
          repository: repository,
        ),
        locale: locale,
      );

  testWidgets('creates a version on closed-period work and changes its status',
      (tester) async {
    await setWindowSize(tester, const Size(1280, 900));
    await tester.pumpWidget(screen());
    await settle(tester);

    expect(find.text('Closed period'), findsOneWidget);
    expect(find.text('No versions yet'), findsWidgets);

    await tester.tap(find.widgetWithText(FilledButton, 'New Version'));
    await tester.pumpAndSettle();
    expect(find.text('Leave empty to use V1'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'What changed'), 'İlk kurgu');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await settle(tester);

    expect(find.text('V1'), findsOneWidget);
    expect(find.text('Latest'), findsOneWidget);
    expect(find.text('İlk kurgu'), findsOneWidget);

    await tester.tap(find.text('Sent'));
    await settle(tester);
    expect(find.text('V1 · Waiting for feedback'), findsOneWidget);

    final detail = (await tester.runAsync(
        () => repository.getRevisionDetail(fixture.closedWorkItemId)))!;
    expect(detail.latestVersion!.sentAt, isNotNull);
  });

  testWidgets(
      'adds, resolves and reopens feedback; financial records unchanged',
      (tester) async {
    await setWindowSize(tester, const Size(1280, 1000));
    final before = (await tester.runAsync(() => snapshotLedgerTables(helper)))!;
    await tester
        .runAsync(() => repository.createVersion(fixture.closedWorkItemId));
    await tester.pumpWidget(screen());
    await settle(tester);
    expect(find.text('No open feedback.'), findsOneWidget);

    // The header button preselects the latest version.
    await tester.tap(find.widgetWithText(FilledButton, 'Add Feedback'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New Scope'));
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Request'), '9:16 versiyonu');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Timecode (optional)'), '00:43');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await settle(tester);

    expect(inFeedbackList(find.text('9:16 versiyonu')), findsOneWidget);
    expect(find.text('00:43'), findsOneWidget);
    expect(find.text('1 new scope request'), findsOneWidget);
    expect(find.textContaining('1 open · 1 total'), findsOneWidget);

    // Resolve: leaves the open list, still shown under "All".
    await tester.tap(find.byTooltip('Mark resolved'));
    await settle(tester);
    expect(inFeedbackList(find.text('9:16 versiyonu')), findsNothing);
    expect(find.text('No open feedback.'), findsOneWidget);
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    expect(inFeedbackList(find.text('9:16 versiyonu')), findsOneWidget);
    expect(find.textContaining('0 open · 1 total'), findsOneWidget);

    // Reopen from the menu.
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reopen').last);
    await settle(tester);
    expect(find.textContaining('1 open · 1 total'), findsOneWidget);

    expect(await tester.runAsync(() => snapshotLedgerTables(helper)), before);
  });

  testWidgets('feedback of a deleted version shows a label', (tester) async {
    await setWindowSize(tester, const Size(1280, 900));
    await tester.runAsync(() async {
      final version = await repository.createVersion(fixture.closedWorkItemId);
      await repository.createFeedback(fixture.closedWorkItemId,
          versionId: version.id, body: 'Yazıyı küçült');
      await repository.softDeleteVersion(version.id);
    });
    await tester.pumpWidget(screen());
    await settle(tester);

    expect(inFeedbackList(find.text('Yazıyı küçült')), findsOneWidget);
    expect(find.textContaining('V1 (deleted)'), findsOneWidget);
    expect(find.text('1 open revision'), findsOneWidget);
  });

  testWidgets('Turkish UI texts', (tester) async {
    await setWindowSize(tester, const Size(1280, 900));
    await tester.runAsync(() async {
      await repository.createVersion(fixture.closedWorkItemId);
      await repository.createFeedback(fixture.closedWorkItemId,
          body: 'Rengi ısıt', timecode: '01:02');
    });
    await tester.pumpWidget(screen(locale: const Locale('tr')));
    await settle(tester);

    expect(find.text('Kapalı dönem'), findsOneWidget);
    expect(find.text('V1 · Değişiklik istendi'), findsOneWidget);
    expect(find.text('1 açık revizyon'), findsOneWidget);
    expect(find.text('Yeni Versiyon'), findsOneWidget);
    expect(find.text('Geri Bildirim Ekle'), findsWidgets);
    expect(find.text('Revizyon'), findsOneWidget);
  });

  testWidgets('wide window shows history in a side panel', (tester) async {
    await setWindowSize(tester, const Size(1280, 900));
    await tester.runAsync(() async {
      final v = await repository.createVersion(fixture.closedWorkItemId);
      await repository.setVersionStatus(v.id, WorkItemVersionStatus.sent);
    });
    await tester.pumpWidget(screen());
    await settle(tester);

    expect(find.byType(TabBar), findsNothing);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('V1 created'), findsOneWidget);
    expect(find.text('V1 sent'), findsOneWidget);
    expect(find.text('Work item created'), findsOneWidget);
    expect(find.text('Work item completed'), findsOneWidget);
  });

  testWidgets('narrow window splits revisions and history into tabs',
      (tester) async {
    await setWindowSize(tester, const Size(600, 900));
    await tester
        .runAsync(() => repository.createVersion(fixture.closedWorkItemId));
    await tester.pumpWidget(screen(locale: const Locale('tr')));
    await settle(tester);

    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('V1 oluşturuldu'), findsNothing);
    await tester.tap(find.text('Geçmiş'));
    await tester.pumpAndSettle();
    expect(find.text('V1 oluşturuldu'), findsOneWidget);
    expect(find.text('İş oluşturuldu'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
