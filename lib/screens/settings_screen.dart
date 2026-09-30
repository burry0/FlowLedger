import 'package:flowledger/app/currency_controller.dart';
import 'package:flowledger/app/locale_controller.dart';
import 'package:flowledger/app/theme_controller.dart';
import 'package:flowledger/core/app_constants.dart';
import 'package:flowledger/l10n/l10n.dart';
import 'package:flowledger/l10n/language_options.dart';
import 'package:flowledger/widgets/backup_section.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.themeController,
    required this.localeController,
    required this.currencyController,
  });

  final ThemeController themeController;
  final LocaleController localeController;
  final CurrencyController currencyController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/branding/flowledger_icon.png',
                      width: 40, height: 40),
                  const SizedBox(height: 12),
                  Text(context.l10n.settings,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    '${AppConstants.appName} ${context.l10n.localOnlyDescription}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.storage_outlined),
                    title: Text(context.l10n.localDatabase),
                    subtitle: Text(context.l10n.cloudSyncOff),
                  ),
                  const Divider(height: 32),
                  const BackupSection(),
                  const Divider(height: 32),
                  Text(context.l10n.theme,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ThemeMode>(
                    initialValue: themeController.themeMode,
                    decoration: InputDecoration(labelText: context.l10n.theme),
                    items: [
                      DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text(context.l10n.system)),
                      DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text(context.l10n.light)),
                      DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text(context.l10n.dark)),
                    ],
                    onChanged: (value) {
                      if (value != null) themeController.setThemeMode(value);
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(context.l10n.language,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: localeController.locale?.languageCode,
                    decoration:
                        InputDecoration(labelText: context.l10n.language),
                    items: [
                      for (final option in languageOptions)
                        DropdownMenuItem(
                            value: option.code, child: Text(option.nativeName)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        localeController.setLocale(Locale(value));
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(context.l10n.currency,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: currencyController.currency.code,
                    decoration: InputDecoration(
                      labelText: context.l10n.currency,
                      helperText: context.l10n.currencyHelper,
                    ),
                    items: [
                      for (final currency in CurrencyController.supported)
                        DropdownMenuItem(
                          value: currency.code,
                          child: Text('${currency.symbol}  ${currency.code}'),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) currencyController.setCurrency(value);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
