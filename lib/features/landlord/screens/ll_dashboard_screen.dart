import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

    final money = NumberFormat.simpleCurrency(locale: 'en_US');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text('Landlord Dashboard', style: t.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text('Quick snapshot across your portfolio', style: t.textTheme.bodyMedium),
        const SizedBox(height: 14),

        if (properties == 0 || units == 0) ...[
          _InfoBanner(
            title: 'Add your first property',
            subtitle:
                'Once you add properties and units, you’ll see rent, maintenance, and activity here.',
            actionLabel: 'Add property',
            onAction: () => Navigator.pushNamed(context, '/landlord/add-property'),
          ),
          const SizedBox(height: 12),
        ],

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
            Expanded(child: _kpi(context, label: 'Outstanding', value: money.format(outstanding))),
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
          subtitle: 'Properties → units → unit details',
          onTap: () => _go(context, tabIndex: 1, fallbackRoute: '/landlord/properties'),
        ),
        _actionCard(
          context,
          icon: Icons.payments_rounded,
          title: 'Rent',
          subtitle: 'Review rent ledger and balances',
          onTap: () => _go(context, tabIndex: 2, fallbackRoute: '/landlord/rent'),
        ),
        _actionCard(
          context,
          icon: Icons.build_rounded,
          title: 'Maintenance',
          subtitle: 'Track tickets, assignments, and status',
          onTap: () => _go(context, tabIndex: 3, fallbackRoute: '/landlord/maintenance'),
        ),
        _actionCard(
          context,
          icon: Icons.handyman_rounded,
          title: 'Contractors',
          subtitle: 'Preferred vendors and assignment history',
          onTap: () => _go(context, tabIndex: 4, fallbackRoute: '/landlord/contractors'),
        ),

        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tips', style: t.textTheme.titleSmall),
                const SizedBox(height: 8),
                const Text('• Keep rent and ticket statuses up to date for accurate metrics.'),
                const Text('• Use unit tabs to manage rent, maintenance, documents, and activity.'),
                const Text('• Cloud sync, payments, and permissions will be added in upcoming updates.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _go(BuildContext context, {required int tabIndex, required String fallbackRoute}) {
    if (goToTab != null) {
      goToTab!.call(tabIndex);
      return;
    }
    // If this screen is ever used outside the tab shell, avoid dead-ends.
    Navigator.pushNamed(context, fallbackRoute);
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

class _InfoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _InfoBanner({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.info_outline, color: cs.onSecondaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Text(subtitle, style: t.textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  FilledButton.tonal(
                    onPressed: onAction,
                    child: Text(actionLabel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
