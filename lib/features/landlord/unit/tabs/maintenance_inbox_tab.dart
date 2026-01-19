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
    _tickets = UnitSessionStore.ticketsFor(widget.bundle);
  }

  Future<void> _assign(int i) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => _AssignSheet(contractors: widget.bundle.contractors),
    );

    if (selected == null) return;

    setState(() {
      UnitSessionStore.assignTicket(widget.bundle, _tickets[i].id, selected);
    });
if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assigned to $selected')),
      );
    }
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
                  _tickets.insert(
                    0,
                    MaintenanceTicketRow(
                      id: 'T-${DateTime.now().millisecondsSinceEpoch}',
                      title: 'New ticket (demo)',
                      category: 'General',
                      priority: 'Medium',
                      status: TicketStatus.newTicket,
                      createdAt: 'Today',
                      assignedTo: null,
                    ),
                  );
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
              onTap: () async {
                final updated = await Navigator.of(context).push<MaintenanceTicketRow>(
                  MaterialPageRoute(
                    builder: (_) => _TicketDetailScreen(
                      ticket: x,
                      contractors: widget.bundle.contractors,
                    ),
                  ),
                );
                if (updated != null) {
                  setState(() => _tickets[i] = updated);
                }
              },
              leading: Icon(x.status.icon),
              title: Text(x.title),
              subtitle: Text(
                '${x.category} • ${x.priority} • ${x.status.label}'
                '${x.assignedTo != null ? ' • Assigned: ${x.assignedTo}' : ''}',
              ),
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

class _TicketDetailScreen extends StatefulWidget {
  final MaintenanceTicketRow ticket;
  final List<ContractorRow> contractors;

  const _TicketDetailScreen({
    required this.ticket,
    required this.contractors,
  });

  @override
  State<_TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<_TicketDetailScreen> {
  late MaintenanceTicketRow _t;

  @override
  void initState() {
    super.initState();
    _t = widget.ticket;
  }

  Future<void> _pickAssignee() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => _AssignSheet(contractors: widget.contractors),
    );
    if (selected == null) return;

    setState(() {
      _t = _t.copyWith(status: TicketStatus.assigned, assignedTo: selected);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Assigned to $selected')),
      );
    }
  }

  void _advanceStatus() {
    final next = switch (_t.status) {
      TicketStatus.newTicket => TicketStatus.assigned,
      TicketStatus.assigned => TicketStatus.inProgress,
      TicketStatus.inProgress => TicketStatus.completed,
      TicketStatus.completed => TicketStatus.completed,
    };

    setState(() {
      _t = _t.copyWith(status: next);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final canAssign = _t.status != TicketStatus.completed;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket • ${_t.id}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _t),
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_t.title, style: t.textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text('${_t.category} • Priority ${_t.priority}'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(_t.status.icon, size: 18),
                      const SizedBox(width: 8),
                      Text('Status: ${_t.status.label}', style: t.textTheme.titleSmall),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Created: ${_t.createdAt}'),
                  const SizedBox(height: 6),
                  Text(_t.assignedTo == null ? 'Assigned: (none)' : 'Assigned: ${_t.assignedTo}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Actions', style: t.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: canAssign ? _pickAssignee : null,
                        icon: const Icon(Icons.assignment_ind_outlined),
                        label: Text(_t.assignedTo == null ? 'Assign contractor' : 'Reassign'),
                      ),
                      FilledButton.icon(
                        onPressed: _t.status == TicketStatus.completed ? null : _advanceStatus,
                        icon: const Icon(Icons.sync_alt_rounded),
                        label: Text(_t.status == TicketStatus.completed ? 'Completed' : 'Advance status'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Demo: add internal note')),
                          );
                        },
                        icon: const Icon(Icons.note_add_outlined),
                        label: const Text('Add note'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.history_rounded),
              title: const Text('Activity (demo)'),
              subtitle: Text(
                '• ${_t.createdAt}: Ticket created\n'
                '• Today: Status is ${_t.status.label}'
                '${_t.assignedTo != null ? '\n• Assigned to ${_t.assignedTo}' : ''}',
              ),
            ),
          ),
        ],
      ),
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
