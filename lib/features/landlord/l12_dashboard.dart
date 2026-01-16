import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/providers.dart';

class LandlordDashboardScreen extends ConsumerWidget {
  const LandlordDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rent = ref.watch(rentBoardProvider);
    final tickets = ref.watch(ticketsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('L-12 • Landlord Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('At a glance'),
          Row(
            children: [
              Expanded(child: _metricCard(context, 'Rent Due', rent, (list) => list.where((e) => e.status != 'Paid').length.toString())),
              const SizedBox(width: 12),
              Expanded(child: _metricCard(context, 'Open Tickets', tickets, (list) => list.where((e) => e.status != 'Closed').length.toString())),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _quickAction(context, 'Rent Board', Icons.payments_outlined, '/L-23')),
              const SizedBox(width: 12),
              Expanded(child: _quickAction(context, 'Maintenance', Icons.build_outlined, '/L-30')),
            ],
          ),
          const SizedBox(height: 18),
          _sectionTitle('Next actions'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.warning_amber_outlined),
              title: const Text('3 tenants are late'),
              subtitle: const Text('Tap to view late payments and send reminders.'),
              onTap: () => Navigator.pushNamed(context, '/L-23'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.water_damage_outlined),
              title: const Text('High priority ticket: Leaking sink'),
              subtitle: const Text('Approve and assign a contractor.'),
              onTap: () => Navigator.pushNamed(context, '/L-31'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.payments_outlined), label: 'Rent'),
          NavigationDestination(icon: Icon(Icons.build_outlined), label: 'Maintenance'),
        ],
        onDestinationSelected: (i) {
          if (i == 1) Navigator.pushNamed(context, '/L-23');
          if (i == 2) Navigator.pushNamed(context, '/L-30');
        },
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  );

  Widget _metricCard<T>(BuildContext context, String label, AsyncValue<T> value, String Function(dynamic) getter) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: value.when(
          loading: () => _metric(label, '…'),
          error: (e, st) => _metric(label, '!'),
          data: (d) => _metric(label, getter(d)),
        ),
      ),
    );
  }

  Widget _metric(String label, String val) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Text(val, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
    ],
  );

  Widget _quickAction(BuildContext context, String label, IconData icon, String route) {
    return FilledButton.tonalIcon(
      onPressed: () => Navigator.pushNamed(context, route),
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
