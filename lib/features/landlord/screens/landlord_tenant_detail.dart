import 'package:flutter/material.dart';
import 'package:ayrnow/features/landlord/models/property_models.dart';

class LandlordTenantDetailScreen extends StatelessWidget {
  final TenantModel tenant;
  const LandlordTenantDetailScreen({super.key, required this.tenant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tenant Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text(tenant.name, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('Phone: ${tenant.phone}\nLease ends: ${tenant.leaseEnds}'),
              isThreeLine: true,
            ),
          ),
          const SizedBox(height: 16),
          Text('Actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.payments_outlined), label: const Text('View rent history')),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.build_outlined), label: const Text('View maintenance tickets')),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(onPressed: () {}, icon: const Icon(Icons.message_outlined), label: const Text('Message tenant')),
        ],
      ),
    );
  }
}
