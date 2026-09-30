import 'package:flowledger/app/currency_controller.dart';
import 'package:flowledger/app/flowledger_app.dart';
import 'package:flowledger/app/locale_controller.dart';
import 'package:flowledger/app/theme_controller.dart';
import 'package:flowledger/services/database_helper.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.initialize();
  final themeController = ThemeController();
  final localeController = LocaleController();
  final currencyController = CurrencyController();
  await themeController.load();
  await localeController.load();
  await currencyController.load();
  runApp(
    FlowLedgerApp(
      themeController: themeController,
      localeController: localeController,
      currencyController: currencyController,
    ),
  );
}
