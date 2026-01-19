import 'package:flutter/material.dart';
import '../mock_unit_data.dart';

class ContractorsTab extends StatefulWidget {
  final UnitBundle bundle;
  const ContractorsTab({super.key, required this.bundle});

  @override
  State<ContractorsTab> createState() => _ContractorsTabState();
}

class _ContractorsTabState extends State<ContractorsTab> {
  late final List<AssignmentHistoryRow> _history =
      List.of(widget.bundle.assignmentHistory);

  Future<void> _assignFlow(ContractorRow c) async {
    // Pick a ticket (demo: only non-completed)
    final openTickets = widget.bundle.maintenanceTickets
        .where((t) => t.status != TicketStatus.completed)
        .toList();

    if (openTickets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No open tickets to assign')),
      );
      return;
    }

    MaintenanceTicketRow selectedTicket = openTickets.first;
    String priority = 'Medium';

    final ok = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final media = MediaQuery.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: media.viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Assign contractor', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),

              DropdownButtonFormField<MaintenanceTicketRow>(
                value: selectedTicket,
                decoration: const InputDecoration(labelText: 'Ticket'),
                items: openTickets
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text('${t.title} • ${t.category}'),
                        ))
                    .toList(),
                onChanged: (v) => selectedTicket = v ?? selectedTicket,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: const [
                  DropdownMenuItem(value: 'Low', child: Text('Low')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'High', child: Text('High')),
                ],
                onChanged: (v) => priority = v ?? 'Medium',
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    if (ok != true) return;

    setState(() {
      _history.insert(
        0,
        AssignmentHistoryRow(
          title: selectedTicket.title,
          contractor: c.name,
          date: 'Today',
          status: 'Assigned • $priority',
        ),
      );
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assigned ${c.name} to "${selectedTicket.title}"')),
      );
    }
  }

  void _historyDetails(AssignmentHistoryRow h) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Assignment details'),
        content: Text(
          'Task: ${h.title}\n'
          'Contractor: ${h.contractor}\n'
          'Date: ${h.date}\n'
          'Status: ${h.status}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text('Preferred contractors', style: t.textTheme.titleMedium),
        const SizedBox(height: 10),
        ...widget.bundle.contractors.map(
          (c) => Card(
            child: ListTile(
              leading: const Icon(Icons.handyman_outlined),
              title: Text(c.name),
              subtitle: Text('${c.trade} • Rating ${c.rating}'),
              trailing: FilledButton.tonal(
                onPressed: () => _assignFlow(c),
                child: const Text('Assign'),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text('Assignment history', style: t.textTheme.titleMedium),
        const SizedBox(height: 10),
        ..._history.map(
          (h) => Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: Text(h.title),
              subtitle: Text('${h.contractor} • ${h.date} • ${h.status}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _historyDetails(h),
            ),
          ),
        ),
      ],
    );
  }
}
