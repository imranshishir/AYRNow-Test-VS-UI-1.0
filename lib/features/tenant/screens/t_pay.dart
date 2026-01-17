import 'package:flutter/material.dart';
import 'package:ayrnow/features/tenant/screens/t_models.dart';
import 'package:ayrnow/features/tenant/screens/t_rent_flow.dart';

class TenantPayHomeScreen extends StatelessWidget {
  const TenantPayHomeScreen({super.key});

  static const _quickUnit = TenantUnit(
    id: 'uQuick',
    label: 'Apt 2B',
    rentCents: 165000,
    dueDateLabel: 'Due Jan 1',
    isOverdue: true,
  );

  static const _quickProperty = TenantProperty(
    id: 'pQuick',
    name: 'Harlem Gardens',
    address: '1142 Harlem Rd, Cheektowaga, NY',
    units: [_quickUnit],
  );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      children: [
        Text('Pay', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text('Quick actions for tenant payments.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next due', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text('${_quickUnit.label} • ${money(_quickUnit.rentCents)}',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Chip(label: Text(_quickUnit.isOverdue ? 'Overdue' : 'Due')),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TenantPayRentScreen(property: _quickProperty, unit: _quickUnit),
                      ),
                    );
                  },
                  icon: const Icon(Icons.payments),
                  label: const Text('Pay now'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
