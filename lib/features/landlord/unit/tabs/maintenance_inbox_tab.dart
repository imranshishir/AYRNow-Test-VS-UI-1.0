import 'package:flutter/material.dart';
import '../mock_unit_data.dart';

class MaintenanceInboxTab extends StatefulWidget {
  final UnitBundle bundle;
  const MaintenanceInboxTab({super.key, required this.bundle});

  @override
  State<MaintenanceInboxTab> createState() => _MaintenanceInboxTabState();
}

class _MaintenanceInboxTabState extends State<MaintenanceInboxTab> {
  late List<MaintenanceTicketRow> _tickets;

  @override
  void initState() {
    super.initState();
    _tickets = List.of(widget.bundle.maintenanceTickets);
  }

  void _assign(int i) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => _AssignSheet(contractors: widget.bundle.contractors),
    );

    if (selected == null) return;

    setState(() {
      _tickets[i] = _tickets[i].copyWith(
        status: TicketStatus.assigned,
        assignedTo: selected,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Assigned to $selected')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          children: [
            Expanded(child: Text('Tickets', style: t.textTheme.titleMedium)),
            FilledButton.tonalIcon(
              onPressed: () {
                setState(() {
                  _tickets.insert(0, MaintenanceTicketRow(
                    id: 'T-${DateTime.now().millisecondsSinceEpoch}',
                    title: 'New ticket (demo)',
                    category: 'General',
                    priority: 'Medium',
                    status: TicketStatus.newTicket,
                    createdAt: 'Today',
                    assignedTo: null,
                  ));
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('New'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate(_tickets.length, (i) {
          final x = _tickets[i];
          return Card(
            child: ListTile(
              leading: Icon(x.status.icon),
              title: Text(x.title),
              subtitle: Text('${x.category} • ${x.priority} • ${x.status.label}'
                  '${x.assignedTo != null ? ' • Assigned: ${x.assignedTo}' : ''}'),
              trailing: x.status == TicketStatus.completed
                  ? const SizedBox.shrink()
                  : FilledButton.tonal(
                      onPressed: () => _assign(i),
                      child: Text(x.assignedTo == null ? 'Assign' : 'Reassign'),
                    ),
            ),
          );
        }),
      ],
    );
  }
}

class _AssignSheet extends StatelessWidget {
  final List<ContractorRow> contractors;
  const _AssignSheet({required this.contractors});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
        children: [
          const Text('Assign contractor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...contractors.map((c) => Card(
                child: ListTile(
                  leading: const Icon(Icons.handyman_outlined),
                  title: Text(c.name),
                  subtitle: Text('${c.trade} • Rating ${c.rating}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(context, c.name),
                ),
              )),
        ],
      ),
    );
  }
}
