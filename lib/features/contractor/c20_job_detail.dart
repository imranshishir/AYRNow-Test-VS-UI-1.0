import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/job.dart';

const _demoJob = ContractorJob(
  id: 'JOB-501',
  property: 'Harlem Rd Apartments',
  issue: 'Replace faucet',
  distanceText: '2.3 mi',
  status: 'Invited',
);

Color _statusColor(String status) {
  switch (status) {
    case 'Invited':
      return Colors.blue;
    case 'InProgress':
      return Colors.orange;
    case 'Completed':
      return Colors.green;
    case 'AwaitingApproval':
      return Colors.amber;
    default:
      return Colors.grey;
  }
}

class JobDetailScreen extends ConsumerWidget {
  const JobDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const job = _demoJob;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('C-20 • Job Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          job.id,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Chip(
                        label: Text(
                          job.status,
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: _statusColor(job.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(job.property, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 4),
                  Text(job.issue, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text('Distance: ${job.distanceText}',
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Job Details', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Replace the kitchen faucet with a new single-handle model. '
            'Shut off water supply, remove old fixture, install new faucet, '
            'and test for leaks.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.grey.shade200,
            child: const SizedBox(
              height: 160,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Location Map'),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const ListTile(
            leading: Icon(Icons.timer_outlined),
            title: Text('Estimated Time'),
            subtitle: Text('2-3 hours'),
          ),
          const ListTile(
            leading: Icon(Icons.attach_money),
            title: Text('Budget'),
            subtitle: Text('\$350'),
          ),
          const SizedBox(height: 24),
          if (job.status == 'Invited')
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Job accepted (demo).')),
                );
              },
              icon: const Icon(Icons.check),
              label: const Text('Accept Job'),
            ),
          if (job.status == 'InProgress') ...[
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Marked complete (demo).')),
                );
              },
              icon: const Icon(Icons.done_all),
              label: const Text('Mark Complete'),
            ),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Contact landlord (demo).')),
              );
            },
            icon: const Icon(Icons.phone),
            label: const Text('Contact Landlord'),
          ),
        ],
      ),
    );
  }
}
