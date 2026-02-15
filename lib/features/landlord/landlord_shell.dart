import 'package:flutter/material.dart';
import 'package:ayrnow/features/landlord/screens/landlord_demo_store.dart';
import 'package:ayrnow/features/landlord/screens/ll_dashboard_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/features/community/screens/community_transfer_inbox_screen.dart';

import 'package:ayrnow/state/role_provider.dart';
import 'package:ayrnow/core/models/user_role.dart';

// Tabs (reuse your existing landlord screens)
import 'package:ayrnow/features/landlord/screens/ll_properties_list_screen.dart';
import 'package:ayrnow/features/landlord/screens/landlord_rent_screen.dart';
import 'package:ayrnow/features/community/screens/community_tab_screen.dart';
import 'package:ayrnow/features/landlord/screens/landlord_maint_pros_shell_screen.dart';
import 'package:ayrnow/features/account_management/screens/managed_users_screen.dart';

class LandlordShell extends ConsumerStatefulWidget {
  const LandlordShell({super.key});

  @override
  ConsumerState<LandlordShell> createState() => _LandlordShellState();
}

class _LandlordShellState extends ConsumerState<LandlordShell> {
  int _index = 0;

  static const _labels = <String>[
    'Dashboard',
    'Properties',
    'Rent',
    'Maintenance',
    'Community',
  ];

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(currentRoleProvider);

    final store = LandlordDemoStore();

    return Scaffold(
      appBar: AppBar(
        title: Text('AYRNOW • ${role.short} • ${_labels[_index]}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'switch') {}
              if (v == 'transfers') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CommunityTransferInboxScreen()),
                );
              }
              if (v == 'invites') {
                Navigator.of(context).pushNamed('/landlord/invites');
              }
              if (v == 'managed') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ManagedUsersScreen(isLandlord: true),
                  ),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'switch', child: Text('Switch role')),
              PopupMenuItem(value: 'managed', child: Text('Managed Users')),
              PopupMenuItem(value: 'transfers', child: Text('Tenant Transfers')),
              PopupMenuItem(value: 'invites', child: Text('Pending Invites')),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          LlDashboardScreen(store: store, goToTab: (i) {
            final next = (i == 4) ? 3 : i;
            setState(() => _index = next.clamp(0, _labels.length - 1));
          }),
          LlPropertiesListScreen(),
          LandlordRentScreen(store: store),
          LandlordMaintProsShellScreen(store: store),
          const CommunityTabScreen(isLandlord: true),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.apartment_rounded), label: 'Properties'),
          NavigationDestination(icon: Icon(Icons.payments_rounded), label: 'Rent'),
          NavigationDestination(icon: Icon(Icons.build_rounded), label: 'Maintain'),
          NavigationDestination(icon: Icon(Icons.forum_outlined), selectedIcon: Icon(Icons.forum), label: 'Community'),
        ],
      ),
    );
  }
}
