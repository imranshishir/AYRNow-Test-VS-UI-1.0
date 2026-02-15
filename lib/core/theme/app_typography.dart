import 'package:flutter/material.dart';

/// Typography hierarchy for AYRNOW.
/// Headline → Title → Body → Caption. Clean, readable, accessible.
abstract class AppTypography {
  AppTypography._();

  static TextTheme textTheme(ColorScheme scheme) {
    final onSurface = scheme.onSurface;
    final onSurfaceVariant = scheme.onSurfaceVariant;
    return TextTheme(
      // Headline
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: onSurface,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: onSurface,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onSurface,
        height: 1.35,
      ),
      // Title
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: onSurface,
        height: 1.35,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: onSurface,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05,
        color: onSurface,
        height: 1.4,
      ),
      // Body
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        color: onSurface,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: onSurface,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        color: onSurfaceVariant,
        height: 1.35,
      ),
      // Label / Caption
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: onSurface,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: onSurfaceVariant,
        height: 1.35,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: onSurfaceVariant,
        height: 1.3,
      ),
    );
  }
}
