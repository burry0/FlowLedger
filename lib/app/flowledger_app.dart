import 'package:flowledger/app/currency_controller.dart';
import 'package:flowledger/app/locale_controller.dart';
import 'package:flowledger/app/theme_controller.dart';
import 'package:flowledger/core/app_constants.dart';
import 'package:flowledger/core/app_theme.dart';
import 'package:flowledger/core/formatting.dart';
import 'package:flowledger/l10n/app_localizations.dart';
import 'package:flowledger/screens/language_selection_screen.dart';
import 'package:flowledger/screens/navigation_shell.dart';
import 'package:flutter/material.dart';

class FlowLedgerApp extends StatelessWidget {
  const FlowLedgerApp({
    super.key,
    required this.themeController,
    required this.localeController,
    this.currencyController,
  });

  final ThemeController themeController;
  final LocaleController localeController;

  /// Falls back to the default currency (TRY) when null.
  final CurrencyController? currencyController;

  CurrencyController get _currency => currencyController ?? _fallbackCurrency;

  static final _fallbackCurrency = CurrencyController();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([themeController, localeController]),
      builder: (context, child) => CurrencyScope(
        controller: _currency,
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          locale: localeController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.themeMode,
          home: localeController.needsInitialLanguageSelection
              ? LanguageSelectionScreen(localeController: localeController)
              : NavigationShell(
                  themeController: themeController,
                  localeController: localeController,
                  currencyController: _currency,
                ),
        ),
      ),
    );
  }
}
