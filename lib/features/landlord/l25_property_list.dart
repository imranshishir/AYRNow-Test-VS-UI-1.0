import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _Property {
  final String name;
  final String address;
  final int unitCount;

  const _Property({
    required this.name,
    required this.address,
    required this.unitCount,
  });
}

class PropertyListScreen extends ConsumerWidget {
  const PropertyListScreen({super.key});

  static const _properties = <_Property>[
    _Property(
      name: 'Harlem Rd Apartments',
      address: '123 Harlem Rd, Buffalo, NY',
      unitCount: 4,
    ),
    _Property(
      name: 'Downtown Lofts',
      address: '456 Main St, Buffalo, NY',
      unitCount: 6,
    ),
    _Property(
      name: 'Elmwood Plaza',
      address: '789 Elmwood Ave, Buffalo, NY',
      unitCount: 3,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('L-25 • Properties & Units')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _properties.length,
        itemBuilder: (context, index) {
          final p = _properties[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.apartment),
              title: Text(p.name),
              subtitle: Text('${p.address}\n${p.unitCount} units'),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/L-22'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/L-20'),
        icon: const Icon(Icons.add),
        label: const Text('Add Property'),
      ),
    );
  }
}
