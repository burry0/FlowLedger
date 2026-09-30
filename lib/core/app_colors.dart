import 'package:flutter/material.dart';

/// "Calm Ledger" palette: neutral surfaces; colour only for the primary
/// action, key amounts and status dots.
abstract final class AppColors {
  // Dark theme
  static const darkBackground = Color(0xFF0C0E13);
  static const darkSurface = Color(0xFF111419);
  static const darkSurfaceHigh = Color(0xFF1A1F28);
  static const darkOutlineVariant = Color(0xFF1F242E);
  static const darkOutline = Color(0xFF2A303C);
  static const darkOnSurface = Color(0xFFE8ECF3);
  static const darkOnSurfaceVariant = Color(0xFF8C95A6);
  static const darkAccent = Color(0xFF7FC8D8);
  static const darkAccentContainer = Color(0xFF16303A);
  static const darkOnAccentContainer = Color(0xFFD6F1F7);
  static const darkSecondary = Color(0xFF9AA8F0);
  static const darkSecondaryContainer = Color(0xFF1E2338);
  static const darkOnSecondaryContainer = Color(0xFFE2E6FB);
  static const darkWarning = Color(0xFFE0A458);
  static const darkSuccess = Color(0xFF7FBF95);
  static const darkError = Color(0xFFF2A3A3);
  static const darkOnError = Color(0xFF3B0A0A);

  // Light theme
  static const lightBackground = Color(0xFFF5F6F8);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceHigh = Color(0xFFECEFF3);
  static const lightOutlineVariant = Color(0xFFDDE1E8);
  static const lightOutline = Color(0xFF9AA2B1);
  static const lightOnSurface = Color(0xFF151821);
  static const lightOnSurfaceVariant = Color(0xFF5D6676);
  static const lightAccent = Color(0xFF2B7F93);
  static const lightAccentContainer = Color(0xFFDDF0F4);
  static const lightOnAccentContainer = Color(0xFF0E3440);
  static const lightSecondary = Color(0xFF4F5FBF);
  static const lightSecondaryContainer = Color(0xFFE6E9F8);
  static const lightOnSecondaryContainer = Color(0xFF1C2352);
  static const lightWarning = Color(0xFFA8641A);
  static const lightSuccess = Color(0xFF2F7A4A);
  static const lightError = Color(0xFFBA1A1A);

  static Color success(Brightness brightness) =>
      brightness == Brightness.dark ? darkSuccess : lightSuccess;

  static Color warning(Brightness brightness) =>
      brightness == Brightness.dark ? darkWarning : lightWarning;
}
