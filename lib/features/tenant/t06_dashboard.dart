import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/providers.dart';

class TenantDashboardScreen extends ConsumerWidget {
  const TenantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = ref.watch(tenantAmountDueProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('T-06 • Tenant Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: Text('Rent due: \$${due.toStringAsFixed(0)}'),
              subtitle: const Text('Tap to pay rent now'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/T-10'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.build_outlined),
              title: const Text('Maintenance'),
              subtitle: const Text('Create or track a ticket'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/T-20'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Lease'),
              subtitle: const Text('View your lease and signatures'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/T-07'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Receipts'),
              subtitle: const Text('View statements and downloads'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/T-14'),
            ),
          ),
        ],
      ),
    );
  }
}
