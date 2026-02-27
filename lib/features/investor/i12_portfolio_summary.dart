import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PortfolioSummaryScreen extends ConsumerWidget {
  const PortfolioSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('I-12 \u2022 Portfolio Summary')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _summaryCard(theme, 'Properties', '3', Icons.apartment_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _summaryCard(theme, 'Total Units', '13', Icons.door_front_door_outlined)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _summaryCard(theme, 'Occupancy', '92%', Icons.people_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _summaryCard(theme, 'Monthly Revenue', '\$18,400', Icons.trending_up_outlined)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Performance',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Container(
              height: 180,
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.show_chart_outlined,
                      size: 48, color: theme.colorScheme.outline),
                  const SizedBox(height: 8),
                  Text('Performance chart',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.outline)),
                  Text('Coming soon',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.outline)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Recent Activity',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: const Icon(Icons.payments_outlined, size: 20),
                  ),
                  title: const Text('Rent collected — Unit 2B'),
                  subtitle: const Text('\$1,450 received'),
                  trailing: Text('2h ago',
                      style: theme.textTheme.bodySmall),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: const Icon(Icons.build_outlined, size: 20),
                  ),
                  title: const Text('Maintenance completed — Unit 1A'),
                  subtitle: const Text('AC repair finished'),
                  trailing: Text('1d ago',
                      style: theme.textTheme.bodySmall),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: const Icon(Icons.person_add_outlined, size: 20),
                  ),
                  title: const Text('New tenant moved in — Unit 4D'),
                  subtitle: const Text('Lease signed for 12 months'),
                  trailing: Text('3d ago',
                      style: theme.textTheme.bodySmall),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
      ThemeData theme, String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
