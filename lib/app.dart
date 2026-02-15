import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/core/theme/app_theme.dart';
import 'package:ayrnow/features/auth/screens/auth_wrapper.dart';
import 'package:ayrnow/routes.dart';

class AyrNowApp extends ConsumerWidget {
  const AyrNowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AYRNOW',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: const AuthWrapper(),
    );
  }
}
