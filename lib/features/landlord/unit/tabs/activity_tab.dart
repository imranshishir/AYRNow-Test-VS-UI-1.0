import 'package:flutter/material.dart';
import '../mock_unit_data.dart';

class ActivityTab extends StatelessWidget {
  final UnitBundle bundle;
  const ActivityTab({super.key, required this.bundle});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    final labels = _bundleLabels(bundle);
    final propertyName = labels.$1;
    final unitLabel = labels.$2;

    // Mock-but-realistic activity feed that is unit-scoped and "dynamic"
    // without hard-coding bundle field names.
    final events = <_ActivityEvent>[
      _ActivityEvent(
        title: 'Rent updated',
        subtitle: 'Payment status updated for $propertyName • $unitLabel',
        when: DateTime.now().subtract(const Duration(hours: 3)),
        icon: Icons.payments_outlined,
        category: 'Rent',
      ),
      _ActivityEvent(
        title: 'Maintenance ticket created',
        subtitle: 'New issue logged for $propertyName • $unitLabel',
        when: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        icon: Icons.build_outlined,
        category: 'Maintenance',
      ),
      _ActivityEvent(
        title: 'Contractor assigned',
        subtitle: 'A vendor was assigned to a maintenance ticket',
        when: DateTime.now().subtract(const Duration(days: 1)),
        icon: Icons.handyman_outlined,
        category: 'Contractors',
      ),
      _ActivityEvent(
        title: 'Document added',
        subtitle: 'A lease/receipt was added for the unit',
        when: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
        icon: Icons.article_outlined,
        category: 'Documents',
      ),
    ]..sort((a, b) => b.when.compareTo(a.when));

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
          'Timeline for $propertyName • $unitLabel',
          style: t.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),

        if (events.isEmpty)
          _EmptyState(onAddNote: () => _toast(context, 'Notes are coming soon.'))
        else
          ...events.map((e) => _EventCard(event: e, onTap: () => _openEvent(context, e))),

        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.timeline_outlined),
            title: const Text('Timeline improvements'),
            subtitle: const Text('Next: auto-generate from Rent, Tickets, and Documents'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _toast(context, 'Auto-generated activity is coming soon.'),
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
                    const SnackBar(content: Text('Deep-linking will be added when repositories are connected.')),
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

/// Best-effort label extraction without depending on UnitBundle shape.
/// This keeps the UI dynamic and prevents compile-time breakage.
(String, String) _bundleLabels(UnitBundle bundle) {
  final b = bundle as dynamic;

  // Property name candidates
  final propertyName =
      _tryGetString(() => b.property.name) ??
      _tryGetString(() => b.propertyName) ??
      _tryGetString(() => b.propertyLabel) ??
      _tryGetString(() => b.propertyTitle) ??
      'Property';

  // Unit label candidates
  final unitLabel =
      _tryGetString(() => b.unit.label) ??
      _tryGetString(() => b.unitLabel) ??
      _tryGetString(() => b.unitName) ??
      _tryGetString(() => b.unitTitle) ??
      _tryGetString(() => b.unitNumber) ??
      'Unit';

  return (propertyName, unitLabel);
}

String? _tryGetString(String Function() fn) {
  try {
    final v = fn();
    if (v.trim().isEmpty) return null;
    return v;
  } catch (_) {
    return null;
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
