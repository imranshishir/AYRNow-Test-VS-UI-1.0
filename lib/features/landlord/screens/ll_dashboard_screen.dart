import 'package:flutter/material.dart';
import 'package:ayrnow/features/landlord/screens/landlord_demo_store.dart';

class LlDashboardScreen extends StatelessWidget {
  final LandlordDemoStore store;
  final ValueChanged<int>? goToTab;
  const LlDashboardScreen({super.key, required this.store, this.goToTab});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    // Derive basic metrics from existing sample store (no store.properties dependency)
    final propertyNames = <String>{};
    final unitKeys = <String>{};

    for (final r in store.rent) {
      propertyNames.add(r.propertyName);
      unitKeys.add('${r.propertyName}::${r.unitLabel}');
    }
    for (final x in store.tickets) {
      propertyNames.add(x.propertyName);
      unitKeys.add('${x.propertyName}::${x.unitLabel}');
    }

    final properties = propertyNames.length;
    final units = unitKeys.length;

    final outstanding = store.rent
        .where((r) => r.status != 'Paid')
        .fold<double>(0, (sum, r) => sum + r.amount);

    final openTickets = store.tickets.where((x) => x.status != 'Completed').length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text('Landlord Dashboard', style: t.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text('Quick snapshot across your portfolio', style: t.textTheme.bodyMedium),
        const SizedBox(height: 14),

        // KPI Row
        Row(
          children: [
            Expanded(child: _kpi(context, label: 'Properties', value: '$properties')),
            const SizedBox(width: 12),
            Expanded(child: _kpi(context, label: 'Units', value: '$units')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _kpi(context, label: 'Outstanding', value: '\$${outstanding.toStringAsFixed(0)}')),
            const SizedBox(width: 12),
            Expanded(child: _kpi(context, label: 'Open tickets', value: '$openTickets')),
          ],
        ),

        const SizedBox(height: 18),
        Text('Shortcuts', style: t.textTheme.titleMedium),
        const SizedBox(height: 10),

        _actionCard(
          context,
          icon: Icons.apartment_rounded,
          title: 'Properties',
          subtitle: 'Go to property list → units → unit tabs',
          onTap: () => goToTab?.call(1),
        ),
        _actionCard(
          context,
          icon: Icons.payments_rounded,
          title: 'Rent',
          subtitle: 'Search & filter rent ledger; deep-link into unit rent tab',
          onTap: () => goToTab?.call(2),
        ),
        _actionCard(
          context,
          icon: Icons.build_rounded,
          title: 'Maintenance',
          subtitle: 'Tickets inbox; create + assign; deep-link into unit maintenance tab',
          onTap: () => goToTab?.call(3),
        ),
        _actionCard(
          context,
          icon: Icons.handyman_rounded,
          title: 'Contractors',
          subtitle: 'Preferred vendors + assignment history',
          onTap: () => goToTab?.call(4),
        ),

        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next steps (real app readiness)', style: t.textTheme.titleSmall),
                const SizedBox(height: 8),
                Text('• Connect repositories (mock → API later)'),
                Text('• Add auth + real tenant/property IDs'),
                Text('• Stripe payments + webhooks (later, backend chat)'),
                Text('• App Store / Play Store assets + policy pages'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _kpi(BuildContext context, {required String label, required String value}) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: cs.primaryContainer,
              ),
              child: Icon(Icons.auto_graph_rounded, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 3),
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
