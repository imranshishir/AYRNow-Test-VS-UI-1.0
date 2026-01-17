import 'package:flutter/material.dart';
import 'package:ayrnow/features/landlord/models/property_models.dart';

class LandlordUnitDetailScreen extends StatelessWidget {
  final PropertyModel property;
  final UnitModel unit;

  const LandlordUnitDetailScreen({super.key, required this.property, required this.unit});

  @override
  Widget build(BuildContext context) {
    final tenant = unit.tenant;

    return Scaffold(
      appBar: AppBar(title: Text('${property.name} • ${unit.label}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _UnitSummary(unit: unit),
          const SizedBox(height: 16),

          Text('Tenant', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),

          if (tenant == null)
            Card(
              child: ListTile(
                title: const Text('No tenant assigned'),
                subtitle: const Text('Add tenant & create lease to start rent + maintenance tracking.'),
                trailing: const Icon(Icons.person_add_alt_1),
                onTap: () {},
              ),
            )
          else
            Card(
              child: ListTile(
                title: Text(tenant.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('Lease ends: ${tenant.leaseEnds}\n${tenant.phone}'),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pushNamed('/landlord/tenant/detail', arguments: tenant),
              ),
            ),

          const SizedBox(height: 16),
          Text('Next', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: FilledButton.tonal(onPressed: () {}, child: const Text('Rent'))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton.tonal(onPressed: () {}, child: const Text('Maintenance'))),
            ],
          ),
        ],
      ),
    );
  }
}

class _UnitSummary extends StatelessWidget {
  final UnitModel unit;
  const _UnitSummary({required this.unit});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.door_front_door_outlined, color: cs.onSecondaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(unit.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Status: ${unit.status}', style: TextStyle(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
