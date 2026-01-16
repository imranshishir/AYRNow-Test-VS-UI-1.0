import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/state/providers.dart';
import '../../ui/widgets/async_value_view.dart';

class GuardApprovalsQueueScreen extends ConsumerWidget {
  const GuardApprovalsQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvals = ref.watch(approvalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('S-10 • Entry Approvals')),
      body: AsyncValueView(
        value: approvals,
        builder: (items) => ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (context, i) {
            final a = items[i];
            final time = '${DateFormat.jm().format(a.windowStart)}–${DateFormat.jm().format(a.windowEnd)}';
            return Card(
              child: ListTile(
                leading: const Icon(Icons.verified_user_outlined),
                title: Text('${a.visitorName} • ${a.unit}'),
                subtitle: Text('$time • ${a.reason}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Deny (demo)',
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Denied (demo).'))),
                      icon: const Icon(Icons.close),
                    ),
                    IconButton(
                      tooltip: 'Approve (demo)',
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Approved (demo). Logged to S-20.'))),
                      icon: const Icon(Icons.check),
                    ),
                  ],
                ),
                onTap: () => Navigator.pushNamed(context, '/S-11'),
              ),
            );
          },
        ),
        emptyMessage: 'No approval requests right now.',
      ),
    );
  }
}
