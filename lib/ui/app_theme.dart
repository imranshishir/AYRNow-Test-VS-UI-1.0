import 'package:flutter/material.dart';

ThemeData buildAyrnowTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB));

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    cardTheme: const CardThemeData(
      margin: EdgeInsets.symmetric(vertical: 6),
      elevation: 0.5,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
    ),
  );
}
