import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ApprovalDetailScreen extends ConsumerWidget {
  const ApprovalDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final windowStart = DateTime(2026, 2, 27, 9, 0);
    final windowEnd = DateTime(2026, 2, 27, 11, 0);
    final timeFmt = DateFormat.jm();

    return Scaffold(
      appBar: AppBar(title: const Text('S-11 • Approval Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Text(
                      'CM',
                      style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contractor Mike',
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text('ID: APR-201',
                            style: theme.textTheme.bodySmall),
                        const SizedBox(height: 2),
                        Text('Company: Mike\'s Plumbing',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Visit Details', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const ListTile(
            leading: Icon(Icons.apartment),
            title: Text('Unit'),
            subtitle: Text('2B'),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Time Window'),
            subtitle: Text(
                '${timeFmt.format(windowStart)} – ${timeFmt.format(windowEnd)}'),
          ),
          const ListTile(
            leading: Icon(Icons.build),
            title: Text('Reason'),
            subtitle: Text('Plumbing repair'),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Special Instructions'),
            subtitle: Text('Escort to unit. Bring tools through side entrance.'),
          ),
          const Divider(height: 24),
          Text('Tenant Confirmation', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Requested by: A. Johnson, Unit 1A'),
            subtitle: const Text('Status: Confirmed'),
            trailing: Icon(Icons.check_circle,
                color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showConfirmDialog(context, approve: true),
            icon: const Icon(Icons.check),
            label: const Text('Approve Entry'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _showConfirmDialog(context, approve: false),
            icon: const Icon(Icons.close),
            label: const Text('Deny Entry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, {required bool approve}) {
    final action = approve ? 'approve' : 'deny';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${approve ? 'Approve' : 'Deny'} Entry?'),
        content: Text('Are you sure you want to $action entry for Contractor Mike?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Entry ${approve ? 'approved' : 'denied'} (demo).')),
              );
              Navigator.of(context).pop();
            },
            child: Text(approve ? 'Approve' : 'Deny'),
          ),
        ],
      ),
    );
  }
}
