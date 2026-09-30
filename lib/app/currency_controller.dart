import 'package:flowledger/repositories/app_settings_repository.dart';
import 'package:flutter/foundation.dart';

class AppCurrency {
  const AppCurrency(this.code, this.symbol);

  /// ISO 4217 code.
  final String code;
  final String symbol;
}

/// The currency amounts are shown in. Display only; stored amounts are never
/// converted.
class CurrencyController extends ChangeNotifier {
  CurrencyController({AppSettingsRepository? settingsRepository})
      : _settingsRepository = settingsRepository;

  static const supported = <AppCurrency>[
    AppCurrency('TRY', '₺'),
    AppCurrency('USD', r'$'),
    AppCurrency('EUR', '€'),
    AppCurrency('GBP', '£'),
    AppCurrency('RUB', '₽'),
    AppCurrency('CHF', 'CHF'),
  ];

  static const _defaultCode = 'TRY';

  final AppSettingsRepository? _settingsRepository;
  AppCurrency _currency = supported.first;

  AppCurrency get currency => _currency;

  Future<void> load() async {
    final code = await (_settingsRepository ?? AppSettingsRepository())
        .getValue(AppSettingsRepository.currencyCodeKey);
    _currency = _byCode(code ?? _defaultCode) ?? supported.first;
    notifyListeners();
  }

  Future<void> setCurrency(String code) async {
    final next = _byCode(code);
    if (next == null || next.code == _currency.code) return;
    _currency = next;
    notifyListeners();
    await (_settingsRepository ?? AppSettingsRepository())
        .setValue(AppSettingsRepository.currencyCodeKey, next.code);
  }

  static AppCurrency? _byCode(String code) {
    for (final currency in supported) {
      if (currency.code == code) return currency;
    }
    return null;
  }
}
