import 'package:flutter/material.dart';
import 'package:ayrnow/features/landlord/screens/landlord_demo_store.dart';

class LandlordMaintenanceScreen extends StatefulWidget {
  final LandlordDemoStore store;
  const LandlordMaintenanceScreen({super.key, required this.store});

  @override
  State<LandlordMaintenanceScreen> createState() =>
      _LandlordMaintenanceScreenState();
}

class _LandlordMaintenanceScreenState extends State<LandlordMaintenanceScreen> {
  String _q = '';
  String _status = 'All';

  @override
  Widget build(BuildContext context) {
    final list = widget.store.tickets.where((t) {
      final query = _q.trim().toLowerCase();
      final matchesQ = query.isEmpty ||
          t.title.toLowerCase().contains(query) ||
          t.unitLabel.toLowerCase().contains(query) ||
          t.propertyName.toLowerCase().contains(query) ||
          t.id.toLowerCase().contains(query);
      final matchesStatus = _status == 'All' || t.status == _status;
      return matchesQ && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Tickets'),
        actions: [
          IconButton(
            tooltip: 'Create ticket',
            onPressed: () => _createTicketSheet(context),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          _filters(context),
          const SizedBox(height: 12),
          ...list.map((t) => _ticketCard(context, t)),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 36),
              child: Center(
                  child: Text('No tickets match your filter.',
                      style: Theme.of(context).textTheme.bodyMedium)),
            ),
        ],
      ),
    );
  }

  Widget _filters(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Search / Filter',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search), hintText: 'Search tickets…'),
            onChanged: (v) => setState(() => _q = v),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _status,
            onChanged: (v) => setState(() => _status = v ?? 'All'),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All statuses')),
              DropdownMenuItem(value: 'Open', child: Text('Open')),
              DropdownMenuItem(
                  value: 'In progress', child: Text('In progress')),
              DropdownMenuItem(value: 'Completed', child: Text('Completed')),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _ticketCard(BuildContext context, MaintenanceTicket t) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (_) =>
                    _TicketDetailScreen(store: widget.store, ticket: t)))
            .then((_) => setState(() {})),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: const Icon(Icons.confirmation_num_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title,
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                          '${t.propertyName} • ${t.unitLabel} • ${t.createdAge}'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _pill(context, t.priority),
                          const SizedBox(width: 8),
                          _pill(context, t.status),
                          if (t.assignedContractor != null) ...[
                            const SizedBox(width: 8),
                            _pill(context, 'Assigned'),
                          ],
                        ],
                      ),
                    ]),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(BuildContext context, String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border:
            Border.all(color: Theme.of(context).dividerColor.withOpacity(.35)),
      ),
      child: Text(t, style: Theme.of(context).textTheme.labelMedium),
    );
  }

  void _createTicketSheet(BuildContext context) {
    final title = TextEditingController();
    final desc = TextEditingController();
    final prop = TextEditingController(text: 'Elm Street Apartments');
    final unit = TextEditingController(text: 'Apt 101');
    String priority = 'Med';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 18,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Create Ticket', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
              controller: prop,
              decoration: const InputDecoration(labelText: 'Property')),
          const SizedBox(height: 10),
          TextField(
              controller: unit,
              decoration: const InputDecoration(labelText: 'Unit')),
          const SizedBox(height: 10),
          TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: priority,
            onChanged: (v) => priority = v ?? 'Med',
            items: const [
              DropdownMenuItem(value: 'Low', child: Text('Low')),
              DropdownMenuItem(value: 'Med', child: Text('Medium')),
              DropdownMenuItem(value: 'High', child: Text('High')),
            ],
            decoration: const InputDecoration(labelText: 'Priority'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: desc,
            maxLines: 4,
            decoration: const InputDecoration(
                labelText: 'Description', alignLabelWithHint: true),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {
              if (title.text.trim().isEmpty || desc.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Title + Description required.')));
                return;
              }
              widget.store.createTicket(
                MaintenanceTicket(
                  id: 'MT-${DateTime.now().millisecondsSinceEpoch}',
                  propertyName: prop.text.trim(),
                  unitLabel: unit.text.trim(),
                  title: title.text.trim(),
                  priority: priority,
                  status: 'Open',
                  createdAge: 'now',
                  description: desc.text.trim(),
                ),
              );
              Navigator.of(context).pop();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ticket created (demo).')));
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Save'),
          ),
        ]),
      ),
    );
  }
}

class _TicketDetailScreen extends StatelessWidget {
  final LandlordDemoStore store;
  final MaintenanceTicket ticket;
  const _TicketDetailScreen({required this.store, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final t = store.tickets
        .firstWhere((x) => x.id == ticket.id, orElse: () => ticket);

    return Scaffold(
      appBar: AppBar(title: Text('Ticket • ${t.id}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.title,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text('${t.propertyName} • ${t.unitLabel}'),
                    const SizedBox(height: 10),
                    Text(t.description),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      _chip(context, t.priority),
                      _chip(context, t.status),
                      if (t.assignedContractor != null)
                        _chip(context, 'Assigned: ${t.assignedContractor}'),
                    ]),
                  ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Actions',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      onPressed: () => _assignContractor(context, t),
                      icon: const Icon(Icons.handyman_outlined),
                      label: const Text('Assign contractor'),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                              content: Text('Messaging UI next.'))),
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Message tenant'),
                    ),
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Text(t),
    );
  }

  Future<void> _assignContractor(
      BuildContext context, MaintenanceTicket t) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const ListTile(title: Text('Select contractor')),
          ...store.contractors.map(
            (c) => ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(c.name),
              subtitle: Text(
                  '${c.trade} • ${c.phone} • ⭐ ${c.rating.toStringAsFixed(1)}'),
              onTap: () => Navigator.of(context).pop(c.name),
            ),
          ),
        ],
      ),
    );

    if (selected != null) {
      store.assignContractor(t.id, selected);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Assigned to $selected (demo).')));
      Navigator.of(context).pop();
    }
  }
}
