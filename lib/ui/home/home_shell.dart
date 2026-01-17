import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/core/models/user_role.dart';
import 'package:ayrnow/state/role_provider.dart';
import 'package:ayrnow/features/landlord/landlord_home.dart';
import 'package:ayrnow/features/tenant/tenant_home.dart';
import 'package:ayrnow/features/contractor/contractor_home.dart';
import 'package:ayrnow/features/guard/guard_home.dart';

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentRoleProvider);
    final isLoggedIn = ref.watch(isLoggedInProvider);

    if (!isLoggedIn) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('AYRNOW • ${role.short}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'switch') {
                ref.read(isLoggedInProvider.notifier).state = false;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'switch', child: Text('Switch role')),
            ],
          ),
        ],
      ),
      body: switch (role) {
        UserRole.landlord => const LandlordHome(),
        UserRole.tenant => const TenantHome(),
        UserRole.contractor => const ContractorHome(),
        UserRole.guard => const GuardHome(),
      },
    );
  }
}
