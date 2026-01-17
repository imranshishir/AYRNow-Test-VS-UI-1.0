import 'package:flutter/material.dart';
import 'package:ayrnow/ui/shared/switch_role_menu.dart';

class LlUnitTenantsScreen extends StatelessWidget {
  final dynamic property;
  final dynamic unit;
  const LlUnitTenantsScreen(
      {super.key, required this.property, required this.unit});

  @override
  Widget build(BuildContext context) {
    final tenants = unit.tenantCount == 0
        ? const <_Tenant>[]
        : const [
            _Tenant(
                name: 'Alex Johnson',
                phone: '(646) 202-3430',
                status: 'Active',
                balance: 0.0),
          ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Tenants • ${unit.label}'),
        actions: const [SwitchRoleMenu()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _Info(propertyName: property.name, unitLabel: unit.label),
          const SizedBox(height: 14),
          if (tenants.isEmpty)
            const _EmptyState()
          else
            ...tenants.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _TenantCard(t: t),
                )),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Next: Add tenant flow')),
            ),
            icon: const Icon(Icons.person_add),
            label: const Text('Add tenant (next)'),
          ),
        ],
      ),
    );
  }
}

class _Tenant {
  final String name;
  final String phone;
  final String status;
  final double balance;
  const _Tenant(
      {required this.name,
      required this.phone,
      required this.status,
      required this.balance});
}

class _Info extends StatelessWidget {
  final String propertyName;
  final String unitLabel;
  const _Info({required this.propertyName, required this.unitLabel});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cs.surfaceContainerHighest,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(propertyName, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text('Unit: $unitLabel', style: Theme.of(context).textTheme.bodyMedium),
      ]),
    );
  }
}

class _TenantCard extends StatelessWidget {
  final _Tenant t;
  const _TenantCard({required this.t});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cs.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: cs.secondaryContainer,
            child: Icon(Icons.person, color: cs.onSecondaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.name, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              Text('${t.status} • ${t.phone}',
                  style: Theme.of(context).textTheme.bodyMedium),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: t.balance > 0 ? cs.errorContainer : cs.primaryContainer,
            ),
            child: Text(
              t.balance > 0 ? '\$${t.balance.toStringAsFixed(2)} due' : 'Paid',
              style: TextStyle(
                  color: t.balance > 0
                      ? cs.onErrorContainer
                      : cs.onPrimaryContainer),
            ),
          )
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: cs.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: cs.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'No tenant assigned to this unit yet.\nAdd a tenant to start rent collection and maintenance flow.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
