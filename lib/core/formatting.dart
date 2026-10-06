import 'package:flowledger/app/currency_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Provides the selected currency to the widget tree and rebuilds dependents
/// when it changes.
class CurrencyScope extends InheritedNotifier<CurrencyController> {
  const CurrencyScope({
    super.key,
    required CurrencyController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppCurrency of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CurrencyScope>();
    return scope?.notifier?.currency ?? CurrencyController.supported.first;
  }
}

/// Formats amounts and numbers for a language and currency.
class AppFormatter {
  const AppFormatter({required this.localeName, required this.currency});

  final String localeName;
  final AppCurrency currency;

  String money(double value) => NumberFormat.currency(
        locale: localeName,
        name: currency.code,
        symbol: currency.symbol,
        decimalDigits: 2,
      ).format(value);

  /// 2 → "2", 1.5 → "1,5" (tr) / "1.5" (en).
  String number(double value) =>
      NumberFormat('#,##0.##', localeName).format(value);

  /// 0.5 → "%50" (tr) / "50%" (en), rounded to whole percent.
  String percent(double share) =>
      NumberFormat.percentPattern(localeName).format(share);

  /// Parses user input with either "," or "." as the decimal separator.
  static double? parseNumber(String input) {
    final trimmed = input.trim().replaceAll(' ', '');
    if (trimmed.isEmpty) return null;
    final lastComma = trimmed.lastIndexOf(',');
    final lastDot = trimmed.lastIndexOf('.');
    String normalized;
    if (lastComma >= 0 && lastDot >= 0) {
      // The last separator is the decimal one; the other groups thousands.
      normalized = lastComma > lastDot
          ? trimmed.replaceAll('.', '').replaceAll(',', '.')
          : trimmed.replaceAll(',', '');
    } else {
      normalized = trimmed.replaceAll(',', '.');
    }
    return double.tryParse(normalized);
  }
}

extension FormattingContext on BuildContext {
  AppFormatter get formatter => AppFormatter(
        localeName: Localizations.localeOf(this).toLanguageTag(),
        currency: CurrencyScope.of(this),
      );

  String money(double value) => formatter.money(value);

  String number(double value) => formatter.number(value);

  String percent(double share) => formatter.percent(share);
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

/// 30.09.2026
String formatDate(DateTime value) {
  final local = value.toLocal();
  return '${_twoDigits(local.day)}.${_twoDigits(local.month)}.${local.year}';
}

/// 30.09.2026 14:05
String formatDateTime(DateTime value) {
  final local = value.toLocal();
  return '${formatDate(local)} '
      '${_twoDigits(local.hour)}:${_twoDigits(local.minute)}';
}
