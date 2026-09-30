import 'package:flowledger/models/work_item.dart';
import 'package:flowledger/repositories/client_default_category_repository.dart';
import 'package:flowledger/repositories/client_repository.dart';
import 'package:flowledger/repositories/payment_period_repository.dart';
import 'package:flowledger/repositories/payment_repository.dart';
import 'package:flowledger/repositories/work_item_repository.dart';
import 'package:flowledger/services/database_helper.dart';

/// Made-up client data: a paid closed period and an open period with
/// category work (with stages) and one-off work.
class LedgerFixture {
  LedgerFixture({
    required this.clientId,
    required this.closedWorkItemId,
    required this.openCompletedWorkItemId,
    required this.openInProgressWorkItemId,
  });

  final String clientId;
  final String closedWorkItemId;
  final String openCompletedWorkItemId;
  final String openInProgressWorkItemId;

  static Future<LedgerFixture> seed(DatabaseHelper helper) async {
    final clients = ClientRepository(databaseHelper: helper);
    final categories = ClientDefaultCategoryRepository(databaseHelper: helper);
    final periods = PaymentPeriodRepository(databaseHelper: helper);
    final workItems = WorkItemRepository(databaseHelper: helper);
    final payments = PaymentRepository(databaseHelper: helper);

    final client = await clients.createClient('Örnek Stüdyo', 'Kurgu müşteri');
    await categories.createDefaultCategory(
      client.id,
      'Ana video kurgusu',
      4000,
      stepTitles: ['Kaba kurgu', 'Renk', 'Ses'],
    );
    final openCategories =
        await periods.getOpenPeriodCategoriesForClient(client.id);
    final closedWork = await workItems.addWorkItemFromPeriodCategory(
      openCategories.single.id,
      createAsCompleted: true,
    );
    await payments.recordPartialPaymentForOpenPeriod(
        client.id, 1500, DateTime(2026, 8, 5), 'Avans');
    await payments.recordPaymentAndStartNewPeriod(
        client.id, 2500, DateTime(2026, 8, 20), 'Kalan');

    final newCategories =
        await periods.getOpenPeriodCategoriesForClient(client.id);
    final inProgress =
        await workItems.addWorkItemFromPeriodCategory(newCategories.single.id);
    final completed = await workItems.addCustomWorkItem(
      client.id,
      'Thumbnail',
      750,
      2,
      'İki alternatif',
      createAsCompleted: true,
    );
    final steps = await workItems.getStepsForWorkItem(inProgress.id);
    await workItems.updateWorkItemStepDone(steps.first.id, isDone: true);

    assert(closedWork.status == WorkItemStatus.completed);
    return LedgerFixture(
      clientId: client.id,
      closedWorkItemId: closedWork.id,
      openCompletedWorkItemId: completed.id,
      openInProgressWorkItemId: inProgress.id,
    );
  }
}

/// Full contents of the financial and work tables, to check that revision
/// operations leave them unchanged.
Future<Map<String, List<Map<String, Object?>>>> snapshotLedgerTables(
  DatabaseHelper helper,
) async {
  const tables = [
    'clients',
    'client_default_categories',
    'client_default_category_steps',
    'payment_periods',
    'period_categories',
    'period_category_steps',
    'work_items',
    'work_item_steps',
    'payments',
    'app_settings',
  ];
  final db = await helper.database;
  return {
    for (final table in tables)
      table: (await db.query(table,
              orderBy: table == 'app_settings' ? 'key' : 'id'))
          .map((row) => Map<String, Object?>.of(row))
          .toList(),
  };
}
