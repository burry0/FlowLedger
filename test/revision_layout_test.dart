import 'package:flowledger/models/work_item_feedback.dart';
import 'package:flowledger/models/work_item_revision_summary.dart';
import 'package:flowledger/models/work_item_version.dart';
import 'package:flowledger/repositories/revision_repository.dart';
import 'package:flowledger/screens/work_item_revisions_screen.dart';
import 'package:flowledger/widgets/revisions/revision_summary_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ledger_fixture.dart';
import 'support/test_database.dart';
import 'support/widget_harness.dart';

void main() {
  group('summary line', () {
    const summary = WorkItemRevisionSummary(
      workItemId: 'w',
      versionCount: 3,
      latestLabel: 'V3',
      latestStatus: WorkItemVersionStatus.sent,
      openRevisionCount: 2,
      openNewScopeCount: 1,
      feedbackCount: 5,
    );

    testWidgets('English', (tester) async {
      await tester.pumpWidget(localizedApp(
          const Scaffold(body: RevisionSummaryLine(summary: summary))));
      await tester.pumpAndSettle();
      expect(
        find.text('V3 · Changes requested · 2 open revisions · '
            '1 new scope request'),
        findsOneWidget,
      );
    });

    testWidgets('Turkish', (tester) async {
      await tester.pumpWidget(localizedApp(
        const Scaffold(body: RevisionSummaryLine(summary: summary)),
        locale: const Locale('tr'),
      ));
      await tester.pumpAndSettle();
      expect(
        find.text('V3 · Değişiklik istendi · 2 açık revizyon · '
            '1 yeni kapsam talebi'),
        findsOneWidget,
      );
    });

    testWidgets('draws nothing without revision records', (tester) async {
      await tester.pumpWidget(localizedApp(const Scaffold(
        body: RevisionSummaryLine(
          summary: WorkItemRevisionSummary(
            workItemId: 'w',
            versionCount: 0,
            openRevisionCount: 0,
            openNewScopeCount: 0,
            feedbackCount: 0,
          ),
        ),
      )));
      expect(find.byType(Text), findsNothing);
    });
  });

  group('narrow window overflow', () {
    late TestDatabase testDatabase;
    late RevisionRepository repository;
    late LedgerFixture fixture;

    setUp(() async {
      testDatabase = await TestDatabase.create();
      final helper = testDatabase.helper();
      fixture = await LedgerFixture.seed(helper);
      repository = RevisionRepository(databaseHelper: helper);
    });
    tearDown(() async => testDatabase.dispose());

    for (final locale in const [Locale('tr'), Locale('en')]) {
      testWidgets('400px wide, ${locale.languageCode}', (tester) async {
        await setWindowSize(tester, const Size(400, 800));
        await tester.runAsync(() async {
          final id = fixture.closedWorkItemId;
          final v1 = await repository.createVersion(id,
              notes: 'Uzun bir açıklama ' * 8,
              link:
                  r'D:\Projeler\Çok\Uzun\Bir\Klasör\Yolu\final_export_v1.mp4');
          await repository.setVersionStatus(v1.id, WorkItemVersionStatus.sent);
          await repository.createFeedback(id,
              versionId: v1.id,
              body: 'Intro müziği biraz daha geç girsin ' * 4,
              timecode: '00:00:43:12');
          await repository.createFeedback(id,
              body: '9:16 versiyonu', kind: WorkItemFeedbackKind.newScope);
          await repository.createVersion(id, label: 'Final teslim versiyonu');
        });
        await tester.pumpWidget(localizedApp(
          WorkItemRevisionsScreen(
            workItemId: fixture.closedWorkItemId,
            title: 'Çok uzun bir iş kalemi başlığı ve ek açıklama',
            repository: repository,
          ),
          locale: locale,
        ));
        await settle(tester);
        expect(tester.takeException(), isNull);

        // The latest version's status selector and feedback rows are visible.
        await tester.scrollUntilVisible(
          find.byType(SegmentedButton<WorkItemVersionStatus>),
          200,
          scrollable: find.byType(Scrollable).at(1),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.tap(find.byType(Tab).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
