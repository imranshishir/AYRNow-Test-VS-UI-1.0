import 'package:flutter/material.dart';
import 'package:ayrnow/features/landlord/screens/landlord_demo_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ayrnow/state/role_provider.dart';
import 'package:ayrnow/core/models/user_role.dart';

// Tabs (reuse your existing landlord screens)
import 'package:ayrnow/features/landlord/landlord_home.dart';
import 'package:ayrnow/features/landlord/screens/ll_properties_list_screen.dart';
import 'package:ayrnow/features/landlord/screens/landlord_rent_screen.dart';
import 'package:ayrnow/features/landlord/screens/landlord_maintenance_screen.dart';
import 'package:ayrnow/features/landlord/screens/landlord_contractors_screen.dart';

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
    'Contractors',
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
              if (v == 'switch') {
                // go back to role selection/login
                ref.read(isLoggedInProvider.notifier).state = false;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'switch', child: Text('Switch role')),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          LandlordHome(),
          LlPropertiesListScreen(),
          LandlordRentScreen(store: store),
          LandlordMaintenanceScreen(store: store),
          LandlordContractorsScreen(store: store),
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
          NavigationDestination(icon: Icon(Icons.handyman_rounded), label: 'Pros'),
        ],
      ),
    );
  }
}
