import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/state/providers.dart';

class TenantTicketListScreen extends ConsumerWidget {
  const TenantTicketListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('T-21 \u2022 My Tickets')),
      body: ticketsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tickets) {
          if (tickets.isEmpty) {
            return const Center(child: Text('No tickets yet.'));
          }
          final sorted = List.of(tickets)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sorted.length,
            itemBuilder: (context, i) {
              final t = sorted[i];
              return Card(
                child: ListTile(
                  title: Text(t.title),
                  subtitle: Row(
                    children: [
                      Text(t.unit),
                      const SizedBox(width: 8),
                      _priorityChip(context, t.priority),
                      const SizedBox(width: 8),
                      _statusChip(context, t.status),
                    ],
                  ),
                  trailing: Text(
                    DateFormat.yMMMd().format(t.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () => Navigator.pushNamed(context, '/T-22'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/T-20'),
        icon: const Icon(Icons.add),
        label: const Text('Create Ticket'),
      ),
    );
  }

  Widget _priorityChip(BuildContext context, String priority) {
    final Color color;
    switch (priority) {
      case 'High':
      case 'Emergency':
        color = Theme.of(context).colorScheme.error;
        break;
      case 'Med':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(priority, style: const TextStyle(fontSize: 11)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: color),
      labelStyle: TextStyle(color: color, fontSize: 11),
      padding: EdgeInsets.zero,
    );
  }

  Widget _statusChip(BuildContext context, String status) {
    return Chip(
      label: Text(status, style: const TextStyle(fontSize: 11)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
