import 'package:flutter/material.dart';
import 'll_unit_tenants_screen.dart';
import 'package:ayrnow/ui/shared/switch_role_menu.dart';

class LlUnitDetailScreen extends StatelessWidget {
  final dynamic property;
  final dynamic unit;
  const LlUnitDetailScreen(
      {super.key, required this.property, required this.unit});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${property.name} • ${unit.label}'),
        actions: const [SwitchRoleMenu()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: cs.surfaceContainerHighest,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(unit.label, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text('Status: ${unit.status}',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _pill(context, 'Unit ID: ${unit.id}'),
                    const SizedBox(width: 8),
                    _pill(context, 'Tenants: ${unit.tenantCount}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text('Quick actions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.group,
            title: 'View tenants',
            subtitle: 'See tenant list, rent status, and contact options.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) =>
                      LlUnitTenantsScreen(property: property, unit: unit)),
            ),
          ),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.receipt_long,
            title: 'Rent ledger (HIFI skeleton)',
            subtitle: 'Coming next: monthly rent, fees, payments.',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Next: Rent ledger screen')),
            ),
          ),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.build_circle,
            title: 'Maintenance (HIFI skeleton)',
            subtitle: 'Coming next: issues, tickets, vendor assignments.',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Next: Maintenance screen')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, String t) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(t, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionCard(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: cs.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: cs.primaryContainer,
              ),
              child: Icon(icon, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ]),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
