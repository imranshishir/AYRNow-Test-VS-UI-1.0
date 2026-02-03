import 'package:flutter/material.dart';

import 'package:ayrnow/features/landlord/screens/landlord_demo_store.dart';
import 'package:ayrnow/features/landlord/screens/landlord_maintenance_screen.dart';
import 'package:ayrnow/features/landlord/screens/landlord_contractors_screen.dart';

class LandlordMaintProsShellScreen extends StatelessWidget {
  final LandlordDemoStore store;

  const LandlordMaintProsShellScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            child: TabBar(
              tabs: const [
                Tab(icon: Icon(Icons.build_rounded), text: 'Tickets'),
                Tab(icon: Icon(Icons.handyman_rounded), text: 'Pros'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                LandlordMaintenanceScreen(store: store),
                LandlordContractorsScreen(store: store),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
