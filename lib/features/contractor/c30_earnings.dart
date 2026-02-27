import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _Payment {
  final String jobId;
  final String property;
  final String date;
  final String amount;

  const _Payment(this.jobId, this.property, this.date, this.amount);
}

const _payments = [
  _Payment('JOB-490', 'Elm St Condos', 'Feb 20, 2026', '\$420'),
  _Payment('JOB-485', 'Harlem Rd Apts', 'Feb 14, 2026', '\$350'),
  _Payment('JOB-478', 'Oak Lane Houses', 'Feb 8, 2026', '\$680'),
  _Payment('JOB-465', 'Pine St Condos', 'Jan 28, 2026', '\$550'),
  _Payment('JOB-460', 'Maple Ave', 'Jan 20, 2026', '\$450'),
];

class EarningsDashboardScreen extends ConsumerStatefulWidget {
  const EarningsDashboardScreen({super.key});

  @override
  ConsumerState<EarningsDashboardScreen> createState() =>
      _EarningsDashboardScreenState();
}

class _EarningsDashboardScreenState
    extends ConsumerState<EarningsDashboardScreen> {
  String _period = 'This Month';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('C-30 • Earnings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _SummaryCard(
                  label: 'This Month', value: '\$2,450', theme: theme),
              const SizedBox(width: 8),
              _SummaryCard(label: 'Pending', value: '\$350', theme: theme),
              const SizedBox(width: 8),
              _SummaryCard(label: 'Total', value: '\$12,800', theme: theme),
            ],
          ),
          const SizedBox(height: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'This Month', label: Text('This Month')),
              ButtonSegment(value: 'Last Month', label: Text('Last Month')),
              ButtonSegment(value: 'This Year', label: Text('This Year')),
            ],
            selected: {_period},
            onSelectionChanged: (v) => setState(() => _period = v.first),
          ),
          const SizedBox(height: 16),
          Text('Recent Payments', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._payments.map((p) => Card(
                child: ListTile(
                  leading: const Icon(Icons.payment),
                  title: Text('${p.jobId} • ${p.property}'),
                  subtitle: Text(p.date),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(p.amount,
                          style: theme.textTheme.bodyLarge),
                      const SizedBox(width: 8),
                      const Chip(label: Text('Paid')),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('View all transactions (demo).')),
              );
            },
            child: const Text('View all transactions'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Text(value,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
