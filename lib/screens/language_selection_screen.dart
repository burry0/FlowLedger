import 'package:flowledger/app/locale_controller.dart';
import 'package:flowledger/core/app_constants.dart';
import 'package:flowledger/l10n/language_options.dart';
import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key, required this.localeController});

  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/branding/flowledger_icon.png',
                    width: 72,
                    height: 72,
                    filterQuality: FilterQuality.high,
                  ),
                  const SizedBox(height: 18),
                  Text(AppConstants.appName,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'Dil seçin · Choose language · Sprache wählen · Выберите язык',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 28),
                  for (final option in languageOptions) ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: () =>
                            localeController.setLocale(Locale(option.code)),
                        child: Text(option.nativeName),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
