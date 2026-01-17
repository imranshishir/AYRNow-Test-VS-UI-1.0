import 'package:flutter/material.dart';

class TenantHome extends StatelessWidget {
  const TenantHome({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      children: [
        Text('Your Home', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rent Due', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                Text('\$1,850', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text('Due in 5 days • Autopay OFF', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demo: Pay Rent')),
                  ),
                  child: const Text('Pay Rent'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.build_circle),
            title: const Text('Maintenance'),
            subtitle: const Text('2 open requests'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Demo: Maintenance')),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: const Text('Messages'),
            subtitle: const Text('Landlord replied 10m ago'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Demo: Messages')),
            ),
          ),
        ),
      ],
    );
  }
}
