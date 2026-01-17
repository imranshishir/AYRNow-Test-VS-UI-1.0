import 'package:flutter/material.dart';
import 'package:ayrnow/features/tenant/screens/t_models.dart';
import 'package:ayrnow/features/tenant/screens/t_rent_flow.dart';

class TenantDashboardScreen extends StatelessWidget {
  const TenantDashboardScreen({super.key});

  static const _props = <TenantProperty>[
    TenantProperty(
      id: 'p1',
      name: 'Harlem Gardens',
      address: '1142 Harlem Rd, Cheektowaga, NY',
      units: [
        TenantUnit(id: 'u1', label: 'Apt 2B', rentCents: 165000, dueDateLabel: 'Due Jan 1', isOverdue: true),
        TenantUnit(id: 'u2', label: 'Apt 3A', rentCents: 155000, dueDateLabel: 'Due Feb 1', isOverdue: false),
      ],
    ),
    TenantProperty(
      id: 'p2',
      name: 'Elmwood Plaza (Commercial)',
      address: 'Elmwood Ave, Buffalo, NY',
      units: [
        TenantUnit(id: 'u3', label: 'Store 12', rentCents: 350000, dueDateLabel: 'Due Jan 15', isOverdue: false),
        TenantUnit(id: 'u4', label: 'Store 18', rentCents: 420000, dueDateLabel: 'Due Jan 15', isOverdue: true),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      children: [
        Text('My Rentals', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text('Tap a property → unit → rent details → pay.',
            style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 14),
        ..._props.map((p) => _PropertyCard(prop: p)),
      ],
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final TenantProperty prop;
  const _PropertyCard({required this.prop});

  @override
  Widget build(BuildContext context) {
    final overdueCount = prop.units.where((u) => u.isOverdue).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TenantPropertyUnitsScreen(property: prop)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.apartment_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(prop.name, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  if (overdueCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Theme.of(context).colorScheme.errorContainer,
                      ),
                      child: Text('$overdueCount overdue',
                          style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(prop.address, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('${prop.units.length} units', style: Theme.of(context).textTheme.labelLarge),
                  const Spacer(),
                  const Icon(Icons.chevron_right),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
