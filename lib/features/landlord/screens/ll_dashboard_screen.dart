import 'package:flutter/material.dart';
import 'package:ayrnow/features/landlord/screens/landlord_demo_store.dart';

class LlDashboardScreen extends StatelessWidget {
  final LandlordDemoStore store;
  final void Function(int index) goToTab;

  const LlDashboardScreen({
    super.key,
    required this.store,
    required this.goToTab,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    // Demo metrics (keep mock/simple)
    final due = store.rent.where((r) => r.status == 'Due' || r.status == 'Late').length;
    final openTickets = store.tickets.where((t) => t.status != 'Completed').length;
    final activeWork = store.workOrders.where((w) => w.status != 'Approved').length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text('Dashboard', style: t.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('Quick snapshot for your portfolio', style: t.textTheme.bodyMedium),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(child: _Metric(label: 'Due/Late', value: '$due')),
            const SizedBox(width: 12),
            Expanded(child: _Metric(label: 'Open tickets', value: '$openTickets')),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(child: _Metric(label: 'Active work', value: '$activeWork')),
            const SizedBox(width: 12),
            Expanded(child: _Metric(label: 'Rent items', value: '${store.rent.length}')),
          ],
        ),

        const SizedBox(height: 12),

        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.apartment_rounded),
                title: const Text('Go to Properties'),
                subtitle: const Text('Manage units and tenants'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => goToTab(1),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.payments_rounded),
                title: const Text('Go to Rent'),
                subtitle: const Text('Ledger, dues, receipts'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => goToTab(2),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.build_rounded),
                title: const Text('Go to Maintenance'),
                subtitle: const Text('Tickets and assignments'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => goToTab(3),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.handyman_rounded),
                title: const Text('Go to Contractors'),
                subtitle: const Text('Assign and track work'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => goToTab(4),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Card(
          child: ListTile(
            leading: const Icon(Icons.bolt_outlined),
            title: const Text('Next: real KPI dashboard'),
            subtitle: const Text('Paid vs Due, open tickets, occupancy, revenue trend'),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.textTheme.labelMedium),
          const SizedBox(height: 6),
          Text(value, style: t.textTheme.titleMedium),
        ],
      ),
    );
  }
}