import 'package:flutter/material.dart';

/// Semantic color system for AYRNOW.
/// Premium, trustworthy, fintech-level. No neon, no heavy shadows.
abstract class AppColors {
  AppColors._();

  // ---------- Light theme ----------
  static const Color lightPrimary = Color(0xFF1B3A6B);
  static const Color lightPrimaryContainer = Color(0xFFE8EEF6);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnPrimaryContainer = Color(0xFF0F2744);

  static const Color lightSecondary = Color(0xFF2E5A8A);
  static const Color lightSecondaryContainer = Color(0xFFD6E4F2);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightOnSecondaryContainer = Color(0xFF1A3656);

  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F2F5);
  static const Color lightOnBackground = Color(0xFF1A1D21);
  static const Color lightOnSurface = Color(0xFF1A1D21);
  static const Color lightOnSurfaceVariant = Color(0xFF5C6269);

  static const Color lightSuccess = Color(0xFF1B6B3C);
  static const Color lightSuccessContainer = Color(0xFFD4EDE0);
  static const Color lightOnSuccess = Color(0xFFFFFFFF);
  static const Color lightOnSuccessContainer = Color(0xFF0D3D21);

  static const Color lightWarning = Color(0xFF8C5E00);
  static const Color lightWarningContainer = Color(0xFFFFE8B8);
  static const Color lightOnWarning = Color(0xFF1A1D21);
  static const Color lightOnWarningContainer = Color(0xFF4D3800);

  static const Color lightError = Color(0xFFB32D2D);
  static const Color lightErrorContainer = Color(0xFFF8DCDC);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightOnErrorContainer = Color(0xFF5C1515);

  static const Color lightTextPrimary = Color(0xFF1A1D21);
  static const Color lightTextSecondary = Color(0xFF5C6269);
  static const Color lightBorder = Color(0xFFDEE1E5);
  static const Color lightBorderFocused = Color(0xFF1B3A6B);

  // ---------- Dark theme ----------
  static const Color darkPrimary = Color(0xFF8BB4E8);
  static const Color darkPrimaryContainer = Color(0xFF2A4A6F);
  static const Color darkOnPrimary = Color(0xFF0F2744);
  static const Color darkOnPrimaryContainer = Color(0xFFD6E4F2);

  static const Color darkSecondary = Color(0xFF9EC4F0);
  static const Color darkSecondaryContainer = Color(0xFF1A3656);
  static const Color darkOnSecondary = Color(0xFF1A3656);
  static const Color darkOnSecondaryContainer = Color(0xFFD6E4F2);

  static const Color darkBackground = Color(0xFF111418);
  static const Color darkSurface = Color(0xFF1A1D21);
  static const Color darkSurfaceVariant = Color(0xFF252A30);
  static const Color darkOnBackground = Color(0xFFE8EAED);
  static const Color darkOnSurface = Color(0xFFE8EAED);
  static const Color darkOnSurfaceVariant = Color(0xFFB0B5BA);

  static const Color darkSuccess = Color(0xFF6BC992);
  static const Color darkSuccessContainer = Color(0xFF0D3D21);
  static const Color darkOnSuccess = Color(0xFF0D3D21);
  static const Color darkOnSuccessContainer = Color(0xFFD4EDE0);

  static const Color darkWarning = Color(0xFFE8B84D);
  static const Color darkWarningContainer = Color(0xFF4D3800);
  static const Color darkOnWarning = Color(0xFF1A1D21);
  static const Color darkOnWarningContainer = Color(0xFFFFE8B8);

  static const Color darkError = Color(0xFFE88A8A);
  static const Color darkErrorContainer = Color(0xFF5C1515);
  static const Color darkOnError = Color(0xFF5C1515);
  static const Color darkOnErrorContainer = Color(0xFFF8DCDC);

  static const Color darkTextPrimary = Color(0xFFE8EAED);
  static const Color darkTextSecondary = Color(0xFFB0B5BA);
  static const Color darkBorder = Color(0xFF3A4048);
  static const Color darkBorderFocused = Color(0xFF8BB4E8);

  // ---------- ColorScheme builders ----------
  static ColorScheme get lightScheme => const ColorScheme.light(
        primary: lightPrimary,
        onPrimary: lightOnPrimary,
        primaryContainer: lightPrimaryContainer,
        onPrimaryContainer: lightOnPrimaryContainer,
        secondary: lightSecondary,
        onSecondary: lightOnSecondary,
        secondaryContainer: lightSecondaryContainer,
        onSecondaryContainer: lightOnSecondaryContainer,
        surface: lightSurface,
        onSurface: lightOnSurface,
        surfaceContainerHighest: lightSurfaceVariant,
        onSurfaceVariant: lightOnSurfaceVariant,
        error: lightError,
        onError: lightOnError,
        errorContainer: lightErrorContainer,
        onErrorContainer: lightOnErrorContainer,
        outline: lightBorder,
        outlineVariant: lightSurfaceVariant,
      );

  static ColorScheme get darkScheme => const ColorScheme.dark(
        primary: darkPrimary,
        onPrimary: darkOnPrimary,
        primaryContainer: darkPrimaryContainer,
        onPrimaryContainer: darkOnPrimaryContainer,
        secondary: darkSecondary,
        onSecondary: darkOnSecondary,
        secondaryContainer: darkSecondaryContainer,
        onSecondaryContainer: darkOnSecondaryContainer,
        surface: darkSurface,
        onSurface: darkOnSurface,
        surfaceContainerHighest: darkSurfaceVariant,
        onSurfaceVariant: darkOnSurfaceVariant,
        error: darkError,
        onError: darkOnError,
        errorContainer: darkErrorContainer,
        onErrorContainer: darkOnErrorContainer,
        outline: darkBorder,
        outlineVariant: darkSurfaceVariant,
      );
}
