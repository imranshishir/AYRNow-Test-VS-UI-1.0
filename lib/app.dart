import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/state/role_provider.dart';
import 'package:ayrnow/ui/shared/app_theme.dart';
import 'package:ayrnow/ui/auth/role_login_screen.dart';
import 'package:ayrnow/ui/home/home_shell.dart';

class AyrNowApp extends ConsumerWidget {
  const AyrNowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedIn = ref.watch(isLoggedInProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AYRNOW',
      theme: AppTheme.light(),
      home: loggedIn ? const HomeShell() : const RoleLoginScreen(),
    );
  }
}
