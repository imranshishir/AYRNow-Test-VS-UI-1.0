import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/state/providers.dart';
import 'login_screen.dart';
import 'app_shell.dart';

/// Root gate: waits for [initialSessionProvider] (boot token + GET /api/v1/me), then shows
/// loading | login | app. No blank screen; simple loading state until resolved.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(initialSessionProvider);
    return session.when(
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading…'),
            ],
          ),
        ),
      ),
      data: (user) => user == null ? const LoginScreen() : const AppShell(),
      error: (_, __) => const LoginScreen(),
    );
  }
}
