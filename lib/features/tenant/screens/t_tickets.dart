import 'package:flutter/material.dart';
import 'package:ayrnow/features/tenant/screens/t_models.dart';

class TenantTicketsScreen extends StatefulWidget {
  const TenantTicketsScreen({super.key});

  @override
  State<TenantTicketsScreen> createState() => _TenantTicketsScreenState();
}

class _TenantTicketsScreenState extends State<TenantTicketsScreen> {
  final List<TenantTicket> _tickets = [
    const TenantTicket(
      id: 'T-1001',
      title: 'Leaking faucet in kitchen',
      category: 'Plumbing',
      status: 'In Progress',
      createdLabel: 'Jan 10',
      description: 'Water leaks under the sink after running for 2–3 minutes.',
    ),
    const TenantTicket(
      id: 'T-1002',
      title: 'Heater making noise',
      category: 'HVAC',
      status: 'Open',
      createdLabel: 'Jan 14',
      description: 'Rattling noise from heater unit at night.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      children: [
        Row(
          children: [
            Expanded(child: Text('Maintenance Tickets', style: Theme.of(context).textTheme.titleLarge)),
            FilledButton.tonalIcon(
              onPressed: () async {
                final created = await Navigator.of(context).push<TenantTicket>(
                  MaterialPageRoute(builder: (_) => const TenantCreateTicketScreen()),
                );
                if (created != null) setState(() => _tickets.insert(0, created));
              },
              icon: const Icon(Icons.add),
              label: const Text('New'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._tickets.map((t) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.build_outlined),
                title: Text(t.title),
                subtitle: Text('${t.category} • ${t.createdLabel}'),
                trailing: Chip(label: Text(t.status)),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => TenantTicketDetailScreen(ticket: t)),
                  );
                },
              ),
            )),
      ],
    );
  }
}

class TenantCreateTicketScreen extends StatefulWidget {
  const TenantCreateTicketScreen({super.key});

  @override
  State<TenantCreateTicketScreen> createState() => _TenantCreateTicketScreenState();
}

class _TenantCreateTicketScreenState extends State<TenantCreateTicketScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  String _cat = 'Plumbing';

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Ticket')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: _cat,
            onChanged: (v) => setState(() => _cat = v ?? _cat),
            items: const [
              DropdownMenuItem(value: 'Plumbing', child: Text('Plumbing')),
              DropdownMenuItem(value: 'HVAC', child: Text('HVAC')),
              DropdownMenuItem(value: 'Electrical', child: Text('Electrical')),
              DropdownMenuItem(value: 'Appliance', child: Text('Appliance')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g., Leaking faucet'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Description', hintText: 'Describe the issue...'),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () {
              final t = TenantTicket(
                id: 'T-${DateTime.now().millisecondsSinceEpoch}',
                title: _title.text.isEmpty ? 'New ticket' : _title.text,
                category: _cat,
                status: 'Open',
                createdLabel: 'Today',
                description: _desc.text,
              );
              Navigator.of(context).pop(t);
            },
            icon: const Icon(Icons.send),
            label: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class TenantTicketDetailScreen extends StatelessWidget {
  final TenantTicket ticket;
  const TenantTicketDetailScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ticket.id)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(ticket.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(label: Text(ticket.category)),
              const SizedBox(width: 8),
              Chip(label: Text(ticket.status)),
              const Spacer(),
              Text(ticket.createdLabel, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
          const SizedBox(height: 14),
          Text('Description', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(ticket.description.isEmpty ? '(No description)' : ticket.description),
          const SizedBox(height: 20),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
          ),
        ],
      ),
    );
  }
}
