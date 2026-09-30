import 'package:flowledger/models/work_item.dart';
import 'package:flowledger/models/work_item_step.dart';
import 'package:flowledger/repositories/work_item_repository.dart';
import 'package:flowledger/services/database_helper.dart';
import 'package:flowledger/widgets/work_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ledger_fixture.dart';
import 'support/test_database.dart';
import 'support/widget_harness.dart';

void main() {
  late TestDatabase testDatabase;
  late DatabaseHelper helper;
  late WorkItemRepository repository;
  late WorkItem workItem;

  setUp(() async {
    testDatabase = await TestDatabase.create();
    helper = testDatabase.helper();
    repository = WorkItemRepository(databaseHelper: helper);
    final fixture = await LedgerFixture.seed(helper);
    final items =
        await repository.getWorkItemsForClientOpenPeriod(fixture.clientId);
    workItem = items
        .singleWhere((item) => item.id == fixture.openInProgressWorkItemId);
  });
  tearDown(() async => testDatabase.dispose());

  Widget tile({
    bool stepsEditable = true,
    void Function(WorkItemStep step, bool isDone)? onStepChanged,
    VoidCallback? onDelete,
  }) {
    return localizedApp(Scaffold(
      body: SingleChildScrollView(
        child: WorkItemTile(
          workItem: workItem,
          repository: repository,
          subtitle: 'Sample subtitle',
          metrics: const [(label: 'Client', value: 'Sample Studio')],
          revisionSummary: null,
          onOpenRevisions: () {},
          onStepChanged: onStepChanged ?? (_, __) {},
          stepsEditable: stepsEditable,
          onDelete: onDelete,
        ),
      ),
    ));
  }

  testWidgets('shows stages and reports stage changes', (tester) async {
    WorkItemStep? changed;
    await tester.pumpWidget(tile(onStepChanged: (step, _) => changed = step));
    await tester.tap(find.text(workItem.title));
    await settle(tester);

    expect(find.text('Sample subtitle'), findsOneWidget);
    expect(find.text('Sample Studio'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNWidgets(3));

    await tester.tap(find.text('Renk'));
    expect(changed?.title, 'Renk');
  });

  testWidgets('read-only stages and hidden actions', (tester) async {
    await tester.pumpWidget(tile(stepsEditable: false));
    await tester.tap(find.text(workItem.title));
    await settle(tester);

    final checkboxes =
        tester.widgetList<CheckboxListTile>(find.byType(CheckboxListTile));
    expect(checkboxes, hasLength(3));
    expect(checkboxes.every((tile) => tile.onChanged == null), isTrue);
    expect(find.text('Delete'), findsNothing);
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Revisions'), findsOneWidget);
  });
}
