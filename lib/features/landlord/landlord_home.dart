import 'package:flutter/material.dart';
import 'package:ayrnow/features/landlord/screens/ll_properties_list_screen.dart';
import 'package:ayrnow/ui/shared/switch_role_menu.dart';

class LandlordHome extends StatelessWidget {
  const LandlordHome({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // Top summary card (HIFI look)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: cs.surfaceContainerHighest,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: cs.primaryContainer,
                ),
                child: Icon(Icons.dashboard, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Landlord Dashboard', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Properties, rent, maintenance, and tenants.', style: Theme.of(context).textTheme.bodyMedium),
                ]),
              ),
              const SwitchRoleMenu(),
            ],
          ),
        ),
        const SizedBox(height: 14),

        _ActionTile(
          icon: Icons.apartment,
          title: 'Properties',
          subtitle: 'View/add properties → units → tenants',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LlPropertiesListScreen()),
          ),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.receipt_long,
          title: 'Rent board (next)',
          subtitle: 'Monthly rent status, overdue, payments',
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Next: Rent board flow')),
          ),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.build_circle,
          title: 'Maintenance inbox (next)',
          subtitle: 'Tickets, vendors, approvals',
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Next: Maintenance inbox flow')),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ]),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
