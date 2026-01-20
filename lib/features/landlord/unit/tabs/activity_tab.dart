import 'package:flutter/material.dart';
import '../mock_unit_data.dart';

class ActivityTab extends StatelessWidget {
  final UnitBundle bundle;
  const ActivityTab({super.key, required this.bundle});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    final items = _buildTimeline(bundle);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          children: [
            Expanded(child: Text('Activity', style: t.textTheme.titleMedium)),
            TextButton.icon(
              onPressed: () => _toast(context, 'Filtering is coming soon.'),
              icon: const Icon(Icons.filter_list_outlined),
              label: const Text('Filter'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Timeline for ${bundle.propertyName} • ${bundle.unitName}',
          style: t.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),

        if (items.isEmpty)
          _EmptyState(onAddNote: () => _toast(context, 'Notes are coming soon.'))
        else
          ...items.map((e) => _EventCard(event: e, onTap: () => _openEvent(context, e))),

        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.timeline_outlined),
            title: const Text('Timeline improvements'),
            subtitle: const Text('Next: persistent activity stream + deep-linking'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _toast(context, 'Sync + deep-linking is coming soon.'),
          ),
        ),
      ],
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openEvent(BuildContext context, _ActivityEvent e) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        final t = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.title, style: t.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text('${e.category} • ${_formatDateTime(e.when)}', style: t.textTheme.bodyMedium),
              const SizedBox(height: 10),
              Text(e.subtitle, style: t.textTheme.bodyMedium),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Deep-linking will be added soon.')),
                  );
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open related item'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityEvent {
  final String title;
  final String subtitle;
  final DateTime when;
  final IconData icon;
  final String category;

  const _ActivityEvent({
    required this.title,
    required this.subtitle,
    required this.when,
    required this.icon,
    required this.category,
  });
}

List<_ActivityEvent> _buildTimeline(UnitBundle b) {
  // No real timestamps in the model yet; create stable “recent-looking” times.
  // This keeps the UX dynamic from existing lists while staying backend-ready.
  final now = DateTime.now();
  final items = <_ActivityEvent>[];

  // Rent ledger
  for (var i = 0; i < b.rentLedger.length; i++) {
    final r = b.rentLedger[i];
    final when = now.subtract(Duration(days: 2 + i));
    items.add(
      _ActivityEvent(
        title: 'Rent: ${r.monthLabel} • ${r.status.label}',
        subtitle: 'Amount ${r.amount} • Due ${r.dueDate}',
        when: when,
        icon: Icons.payments_outlined,
        category: 'Rent',
      ),
    );
  }

  // Maintenance tickets
  for (var i = 0; i < b.maintenanceTickets.length; i++) {
    final x = b.maintenanceTickets[i];
    final when = now.subtract(Duration(days: 1 + i, hours: 3));
    final assigned = (x.assignedTo == null || x.assignedTo!.trim().isEmpty)
        ? 'Unassigned'
        : 'Assigned to ${x.assignedTo}';
    items.add(
      _ActivityEvent(
        title: 'Ticket: ${x.title}',
        subtitle: '${x.status.label} • $assigned • ${x.category} • Priority ${x.priority}',
        when: when,
        icon: x.status.icon,
        category: 'Maintenance',
      ),
    );
  }

  // Contractor assignment history
  for (var i = 0; i < b.assignmentHistory.length; i++) {
    final h = b.assignmentHistory[i];
    final when = now.subtract(Duration(days: 1 + i, hours: 1));
    items.add(
      _ActivityEvent(
        title: 'Vendor: ${h.contractor}',
        subtitle: '${h.title} • ${h.status} • ${h.date}',
        when: when,
        icon: Icons.handyman_outlined,
        category: 'Contractors',
      ),
    );
  }

  items.sort((a, c) => c.when.compareTo(a.when));
  return items;
}

class _EventCard extends StatelessWidget {
  final _ActivityEvent event;
  final VoidCallback onTap;

  const _EventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(event.icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: t.textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(event.subtitle, style: t.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      '${_formatRelative(event.when)} • ${event.category}',
                      style: t.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddNote;
  const _EmptyState({required this.onAddNote});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No activity yet', style: t.textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(
              'When rent, tickets, or documents change, entries will appear here.',
              style: t.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onAddNote,
              icon: const Icon(Icons.note_add_outlined),
              label: const Text('Add note (coming soon)'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatRelative(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  return _formatDateTime(dt).split(' • ').first;
}

String _formatDateTime(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$y-$m-$d • $hh:$mm';
}
