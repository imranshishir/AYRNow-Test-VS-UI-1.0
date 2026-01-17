import 'package:flutter/material.dart';
import 'package:ayrnow/features/landlord/models/property_models.dart';

class LandlordPropertiesListScreen extends StatelessWidget {
  const LandlordPropertiesListScreen({super.key});

  static final demo = <PropertyModel>[
    PropertyModel(
      id: 'p1',
      name: 'Harlem Rd Apartments',
      address: '1142 Harlem Rd, Cheektowaga, NY',
      type: 'Residential',
      units: [
        UnitModel(
          id: 'u1',
          label: 'Apt 2B',
          status: 'Occupied',
          tenant: TenantModel(
              id: 't1',
              name: 'Sarah K',
              phone: '(555) 100-2000',
              leaseEnds: 'Aug 2026'),
        ),
        UnitModel(
          id: 'u2',
          label: 'Apt 1A',
          status: 'Occupied',
          tenant: TenantModel(
              id: 't2',
              name: 'Mike R',
              phone: '(555) 222-3333',
              leaseEnds: 'May 2026'),
        ),
        const UnitModel(id: 'u3', label: 'Apt 3C', status: 'Vacant'),
      ],
    ),
    PropertyModel(
      id: 'p2',
      name: 'Elmwood Retail Plaza',
      address: 'Elmwood Ave, Buffalo, NY',
      type: 'Commercial',
      units: [
        UnitModel(
          id: 's1',
          label: 'Store 12',
          status: 'Occupied',
          tenant: TenantModel(
              id: 't3',
              name: 'Coffee Spot LLC',
              phone: '(555) 999-0000',
              leaseEnds: 'Dec 2027'),
        ),
        const UnitModel(id: 's2', label: 'Store 14', status: 'Vacant'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Properties')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.of(context).pushNamed('/landlord/properties/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Property'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: demo.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final p = demo[i];
          return Card(
            child: ListTile(
              title: Text(p.name,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle:
                  Text('${p.type} • ${p.address}\n${p.units.length} units'),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context)
                  .pushNamed('/landlord/properties/detail', arguments: p),
            ),
          );
        },
      ),
    );
  }
}
