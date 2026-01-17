import 'package:flutter/material.dart';
import 'package:ayrnow/features/landlord/models/property_models.dart';

class LandlordPropertyDetailScreen extends StatelessWidget {
  final PropertyModel property;
  const LandlordPropertyDetailScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(property.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Header(property: property),
          const SizedBox(height: 16),
          Text('Units', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          ...property.units.map((u) => Card(
                child: ListTile(
                  title: Text(u.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(u.status + (u.tenant != null ? ' • ${u.tenant!.name}' : '')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pushNamed(
                    '/landlord/unit/detail',
                    arguments: {'property': property, 'unit': u},
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final PropertyModel property;
  const _Header({required this.property});

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
              decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.location_city, color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.type, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(property.address, style: TextStyle(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
