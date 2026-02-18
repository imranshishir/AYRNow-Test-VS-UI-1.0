import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/state/role_provider.dart';
import 'package:ayrnow/ui/auth/role_login_screen.dart';
import 'package:ayrnow/ui/home/home_shell.dart';
import 'package:ayrnow/features/auth/screens/login_screen.dart';
import 'package:ayrnow/core/api/providers/auth_controller_provider.dart';
import 'package:ayrnow/core/api/providers/feature_flags_provider.dart';
import 'package:ayrnow/core/api/providers/api_client_provider.dart';

/// Restores session from secure storage when using real API.
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _restoreChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeRestoreSession());
  }

  Future<void> _maybeRestoreSession() async {
    if (_restoreChecked) return;
    if (!ref.read(featureFlagsProvider).auth) {
      _restoreChecked = true;
      return;
    }
    final valid = await ref.read(authControllerProvider.notifier).hasValidSession();
    if (!mounted) return;
    _restoreChecked = true;
    if (valid) {
      ref.read(isLoggedInProvider.notifier).state = true;
      ref.read(hasChosenRoleProvider.notifier).state = true;
      final role = await ref.read(authTokenStoreProvider).getRole();
      ref.read(currentRoleProvider.notifier).state = roleFromBackend(role);
    }
  }

  @override
  Widget build(BuildContext context) {
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
