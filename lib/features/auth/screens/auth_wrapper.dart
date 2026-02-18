import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/core/models/user_role.dart';
import 'package:ayrnow/state/role_provider.dart';
import 'package:ayrnow/ui/auth/role_login_screen.dart';
import 'package:ayrnow/ui/home/home_shell.dart';
import 'package:ayrnow/features/auth/screens/login_screen.dart';
import 'package:ayrnow/core/api/providers/auth_controller_provider.dart';
import 'package:ayrnow/core/api/providers/feature_flags_provider.dart';
import 'package:ayrnow/core/api/providers/api_client_provider.dart';
import 'package:ayrnow/core/api/endpoints/leases_api.dart';
import 'package:ayrnow/core/api/endpoints/units_api.dart';
import 'package:ayrnow/core/session/tenant_context.dart';

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
      final userRole = roleFromBackend(role);
      ref.read(currentRoleProvider.notifier).state = userRole;

      // For tenants: fetch active lease and set tenant context from /me/active + unit
      if (userRole == UserRole.tenant &&
          ref.read(featureFlagsProvider).leases) {
        try {
          final dio = ref.read(apiClientProvider);
          final lease = await LeasesApi(dio).getActiveOrNull();
          if (lease != null && mounted) {
            final unit = await UnitsApi(dio).getById(lease.unitId);
            if (mounted) {
              ref.read(tenantContextProvider.notifier).setContext(
                    TenantContext(
                      tenantAccountId: lease.accountId,
                      selectedPropertyId: unit.propertyId,
                      selectedUnitId: unit.id,
                    ),
                  );
            }
          }
        } catch (_) {
          // Keep default tenant context
        }
      }
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
