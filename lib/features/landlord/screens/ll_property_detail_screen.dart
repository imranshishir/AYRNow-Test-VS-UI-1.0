import 'package:flutter/material.dart';
import 'll_unit_detail_screen.dart';
import 'package:ayrnow/ui/shared/switch_role_menu.dart';

class LlPropertyDetailScreen extends StatelessWidget {
  final dynamic property; // _Property from list screen (kept simple demo)
  const LlPropertyDetailScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final isCommercial = property.type == 'Commercial';
    final units = List.generate(property.units, (i) {
      final num = (i + 1).toString().padLeft(2, '0');
      return _Unit(
        id: isCommercial ? 'S-$num' : 'A-$num',
        label: isCommercial ? 'Store $num' : 'Apt $num',
        status: i % 5 == 0 ? 'Vacant' : 'Occupied',
        tenantCount: i % 5 == 0 ? 0 : 1,
        balance: i % 4 == 0 ? 120.50 : 0.0,
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(property.name),
        actions: const [SwitchRoleMenu()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _HeaderCard(
            title: property.name,
            subtitle: '${property.type} • ${property.city}',
            meta1: property.id,
            meta2: '${property.units} units',
            icon: isCommercial ? Icons.storefront : Icons.apartment,
          ),
          const SizedBox(height: 14),
          Text(isCommercial ? 'Stores' : 'Apartments', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...units.map((u) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _UnitTile(
                  unit: u,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LlUnitDetailScreen(property: property, unit: u)),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _Unit {
  final String id;
  final String label;
  final String status;
  final int tenantCount;
  final double balance;
  const _Unit({required this.id, required this.label, required this.status, required this.tenantCount, required this.balance});
}

class _HeaderCard extends StatelessWidget {
  final String title, subtitle, meta1, meta2;
  final IconData icon;
  const _HeaderCard({required this.title, required this.subtitle, required this.meta1, required this.meta2, required this.icon});

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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
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
              const SizedBox(height: 8),
              Row(children: [
                _pill(context, meta1),
                const SizedBox(width: 8),
                _pill(context, meta2),
              ]),
            ]),
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

class _UnitTile extends StatelessWidget {
  final _Unit unit;
  final VoidCallback onTap;
  const _UnitTile({required this.unit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final vacant = unit.status == 'Vacant';
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: cs.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: vacant ? cs.tertiaryContainer : cs.secondaryContainer,
              child: Icon(vacant ? Icons.home_outlined : Icons.person, size: 18, color: vacant ? cs.onTertiaryContainer : cs.onSecondaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(unit.label, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text('${unit.status} • Tenants: ${unit.tenantCount}', style: Theme.of(context).textTheme.bodyMedium),
              ]),
            ),
            if (unit.balance > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: cs.errorContainer,
                ),
                child: Text('\$${unit.balance.toStringAsFixed(2)} due', style: TextStyle(color: cs.onErrorContainer)),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: cs.primaryContainer,
                ),
                child: Text('Paid', style: TextStyle(color: cs.onPrimaryContainer)),
              ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
