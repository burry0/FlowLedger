import 'package:flowledger/repositories/app_settings_repository.dart';
import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({AppSettingsRepository? settingsRepository})
      : _settingsRepository = settingsRepository ?? AppSettingsRepository();

  final AppSettingsRepository _settingsRepository;
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final saved =
        await _settingsRepository.getValue(AppSettingsRepository.themeModeKey);
    _themeMode = switch (saved) {
      'system' => ThemeMode.system,
      'light' => ThemeMode.light,
      _ => ThemeMode.dark,
    };
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode value) async {
    if (_themeMode == value) return;
    _themeMode = value;
    notifyListeners();
    await _settingsRepository.setValue(
        AppSettingsRepository.themeModeKey, value.name);
  }
}
