import 'package:flowledger/l10n/app_localizations.dart';
import 'package:flowledger/repositories/app_settings_repository.dart';
import 'package:flutter/material.dart';

class LocaleController extends ChangeNotifier {
  LocaleController({AppSettingsRepository? settingsRepository})
      : _settingsRepository = settingsRepository ?? AppSettingsRepository();

  final AppSettingsRepository _settingsRepository;
  Locale? _locale;

  Locale? get locale => _locale;

  static bool isSupported(String code) => AppLocalizations.supportedLocales
      .any((locale) => locale.languageCode == code);
  bool get needsInitialLanguageSelection => _locale == null;

  Future<void> load() async {
    final code = await _settingsRepository
        .getValue(AppSettingsRepository.languageCodeKey);
    if (code != null && isSupported(code)) {
      _locale = Locale(code);
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale value) async {
    if (!isSupported(value.languageCode)) return;
    _locale = value;
    notifyListeners();
    await _settingsRepository.setValue(
      AppSettingsRepository.languageCodeKey,
      value.languageCode,
    );
  }
}
