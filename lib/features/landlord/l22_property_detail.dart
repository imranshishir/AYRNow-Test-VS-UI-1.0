import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _UnitInfo {
  final String label;
  final String tenant;

  const _UnitInfo({required this.label, required this.tenant});
}

class PropertyDetailScreen extends ConsumerWidget {
  const PropertyDetailScreen({super.key});

  static const _propertyName = 'Harlem Rd Apartments';
  static const _address = '123 Harlem Rd, Buffalo, NY';
  static const _totalUnits = 4;

  static const _units = <_UnitInfo>[
    _UnitInfo(label: 'Unit 1A', tenant: 'A. Johnson'),
    _UnitInfo(label: 'Unit 2B', tenant: 'S. Ahmed'),
    _UnitInfo(label: 'Unit 3C', tenant: 'M. Chen'),
    _UnitInfo(label: 'Unit 4D', tenant: 'R. Patel'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('L-22 • Property Detail'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Property (demo)')),
              );
            },
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Property',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _propertyName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(_address, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.door_front_door_outlined,
                          size: 18, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        '$_totalUnits units',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.people_outlined,
                          size: 18, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        '${_units.length}/$_totalUnits occupied',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Units',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final u in _units)
            Card(
              child: ListTile(
                leading: const Icon(Icons.meeting_room_outlined),
                title: Text('${u.label} - ${u.tenant} (Tenant)'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/L-24'),
              ),
            ),
        ],
      ),
    );
  }
}
