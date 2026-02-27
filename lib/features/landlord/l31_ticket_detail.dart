import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/models/ticket.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({super.key});

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  static final _demoTicket = MaintenanceTicket(
    id: 'TCK-1007',
    unit: 'Unit 2B',
    title: 'Leaking sink',
    priority: 'High',
    createdAt: DateTime.now().subtract(const Duration(hours: 20)),
    status: 'Open',
  );

  late String _status;

  @override
  void initState() {
    super.initState();
    _status = _demoTicket.status;
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Med':
        return Colors.orange;
      case 'Low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticket = _demoTicket;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('L-31 • Ticket Detail')),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ticket.id,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Chip(
                        label: Text(ticket.priority),
                        backgroundColor: _priorityColor(ticket.priority)
                            .withValues(alpha: 0.15),
                        side: BorderSide(
                          color: _priorityColor(ticket.priority),
                        ),
                        labelStyle: TextStyle(
                          color: _priorityColor(ticket.priority),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ticket.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.apartment, size: 18),
                      const SizedBox(width: 6),
                      Text(ticket.unit),
                      const SizedBox(width: 16),
                      Chip(
                        label: Text(_status),
                        backgroundColor:
                            colorScheme.secondaryContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Created ${DateFormat.yMMMd().add_jm().format(ticket.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Timeline',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _timelineEntry(
            icon: Icons.report_outlined,
            label: 'Tenant reported',
            subtitle: DateFormat.yMMMd().format(ticket.createdAt),
            isFirst: true,
          ),
          _timelineEntry(
            icon: Icons.visibility_outlined,
            label: 'Landlord reviewed',
            subtitle: DateFormat.yMMMd().format(
              ticket.createdAt.add(const Duration(hours: 2)),
            ),
          ),
          if (_status == 'Assigned')
            _timelineEntry(
              icon: Icons.person_add_outlined,
              label: 'Contractor assigned',
              subtitle: DateFormat.yMMMd().format(DateTime.now()),
              isLast: true,
            ),
          const SizedBox(height: 24),
          Text(
            'Actions',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_status == 'Open')
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FilledButton.icon(
                onPressed: () {
                  setState(() => _status = 'Approved');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ticket approved')),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Approve'),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/L-35'),
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Assign Contractor'),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              setState(() => _status = 'Closed');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ticket closed')),
              );
            },
            icon: const Icon(Icons.close),
            label: const Text('Close Ticket'),
          ),
        ],
      ),
    );
  }

  Widget _timelineEntry({
    required IconData icon,
    required String label,
    required String subtitle,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (!isFirst)
                  Container(width: 2, height: 8, color: Colors.grey.shade400),
                Icon(icon, size: 20),
                if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey.shade400)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
