import 'package:flutter/material.dart';
import 'll_property_detail_screen.dart';
import 'll_add_property_screen.dart';
import 'package:ayrnow/ui/shared/switch_role_menu.dart';

class LlPropertiesListScreen extends StatelessWidget {
  const LlPropertiesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final properties = const [
      _Property(
          id: 'P-1001',
          name: 'Harlem Heights',
          type: 'Residential',
          city: 'Buffalo, NY',
          units: 12),
      _Property(
          id: 'P-2001',
          name: 'Elmwood Plaza',
          type: 'Commercial',
          city: 'Buffalo, NY',
          units: 24),
      _Property(
          id: 'P-3001',
          name: 'Lakeview Villas',
          type: 'Residential',
          city: 'Rochester, NY',
          units: 18),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        actions: const [SwitchRoleMenu()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LlAddPropertyScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add property'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: properties.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final p = properties[i];
          return _PropertyCard(
            p: p,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => LlPropertyDetailScreen(property: p)),
            ),
          );
        },
      ),
    );
  }
}

class _Property {
  final String id;
  final String name;
  final String type;
  final String city;
  final int units;
  const _Property(
      {required this.id,
      required this.name,
      required this.type,
      required this.city,
      required this.units});
}

class _PropertyCard extends StatelessWidget {
  final _Property p;
  final VoidCallback onTap;
  const _PropertyCard({required this.p, required this.onTap});

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
              child: Icon(
                  p.type == 'Commercial' ? Icons.storefront : Icons.apartment,
                  color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('${p.type} • ${p.city}',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ]),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${p.units} units',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
