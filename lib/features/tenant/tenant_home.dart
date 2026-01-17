import 'package:flutter/material.dart';
import 'package:ayrnow/features/tenant/screens/t_dashboard.dart';
import 'package:ayrnow/features/tenant/screens/t_pay.dart';
import 'package:ayrnow/features/tenant/screens/t_tickets.dart';
import 'package:ayrnow/features/tenant/screens/t_profile.dart';

class TenantHome extends StatefulWidget {
  const TenantHome({super.key});

  @override
  State<TenantHome> createState() => _TenantHomeState();
}

class _TenantHomeState extends State<TenantHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      TenantDashboardScreen(),
      TenantPayHomeScreen(),
      TenantTicketsScreen(),
      TenantProfileScreen(),
    ];

    return SafeArea(
      child: Column(
        children: [
          Expanded(child: pages[_index]),
          const Divider(height: 1),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments), label: 'Pay'),
              NavigationDestination(icon: Icon(Icons.build_outlined), selectedIcon: Icon(Icons.build), label: 'Tickets'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ],
      ),
    );
  }
}
