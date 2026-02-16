import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/state/role_provider.dart';
import 'package:ayrnow/ui/auth/role_login_screen.dart';
import 'package:ayrnow/ui/home/home_shell.dart';
import 'package:ayrnow/features/auth/screens/login_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedIn = ref.watch(isLoggedInProvider);
    final hasChosenRole = ref.watch(hasChosenRoleProvider);

    if (!loggedIn) {
      return const LoginScreen();
    }

    if (hasChosenRole) {
      return const HomeShell();
    }

    return RoleLoginScreen(
      onRoleChosen: () {
        ref.read(hasChosenRoleProvider.notifier).state = true;
      },
    );
  }
}
