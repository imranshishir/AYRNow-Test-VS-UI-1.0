import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/state/providers.dart';

class TenantTicketDetailScreen extends ConsumerWidget {
  const TenantTicketDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketsProvider);
    final theme = Theme.of(context);

    return ticketsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('T-22 \u2022 Ticket Detail')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('T-22 \u2022 Ticket Detail')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (tickets) {
        final ticket = tickets.isNotEmpty ? tickets.first : null;
        if (ticket == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('T-22 \u2022 Ticket Detail')),
            body: const Center(child: Text('Ticket not found.')),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('T-22 \u2022 Ticket Detail')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ticket Info',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _infoRow('ID', ticket.id),
                      _infoRow('Title', ticket.title),
                      _infoRow('Unit', ticket.unit),
                      _infoRow('Priority', ticket.priority),
                      _infoRow('Status', ticket.status),
                      _infoRow('Created',
                          DateFormat.yMMMd().format(ticket.createdAt)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Timeline',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _timelineEntry(
                        context,
                        icon: Icons.report_outlined,
                        title: 'You reported this issue',
                        subtitle: DateFormat.yMMMd().format(ticket.createdAt),
                        isFirst: true,
                      ),
                      _timelineEntry(
                        context,
                        icon: Icons.visibility_outlined,
                        title: 'Landlord reviewing',
                        subtitle: 'Pending review',
                        isFirst: false,
                      ),
                      _timelineEntry(
                        context,
                        icon: Icons.engineering_outlined,
                        title: 'Contractor assigned',
                        subtitle: 'Awaiting assignment',
                        isFirst: false,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comments coming soon')),
                  );
                },
                icon: const Icon(Icons.comment_outlined),
                label: const Text('Add Comment'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Cancel Ticket'),
                      content: const Text(
                          'Are you sure you want to cancel this ticket?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('No'),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Ticket cancelled (demo)')),
                            );
                            Navigator.pop(context);
                          },
                          child: const Text('Yes, Cancel'),
                        ),
                      ],
                    ),
                  );
                },
                child: Text('Cancel Ticket',
                    style:
                        TextStyle(color: theme.colorScheme.error)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _timelineEntry(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Expanded(
                      child: Container(
                          width: 2, color: theme.colorScheme.outlineVariant)),
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                if (!isLast)
                  Expanded(
                      child: Container(
                          width: 2, color: theme.colorScheme.outlineVariant)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
