import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/app_theme.dart';
import 'ui/role_selector_screen.dart';
import 'ui/app_shell.dart';
import 'navigation/routes.dart';

void main() {
  runApp(const ProviderScope(child: AyrnowApp()));
}

class AyrnowApp extends StatelessWidget {
  const AyrnowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AYRNOW Phase-2',
      theme: buildAyrnowTheme(),
      initialRoute: '/',
      routes: {
        '/home': (context) => const AppShell(),
        '/': (context) => const RoleSelectorScreen(),
        ...buildRoutes(),
      },
    );
  }
}
