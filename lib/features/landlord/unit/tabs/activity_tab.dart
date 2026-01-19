import 'package:flutter/material.dart';
import '../mock_unit_data.dart';

class ActivityTab extends StatelessWidget {
  final UnitBundle bundle;
  const ActivityTab({super.key, required this.bundle});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    // Demo activity feed (later: real events from backend)
    final feed = [
      ('Rent marked Paid', 'Today • Rent', Icons.attach_money_outlined),
      ('Ticket assigned to contractor', 'Today • Maintenance', Icons.assignment_ind_outlined),
      ('New ticket created', 'Yesterday • Maintenance', Icons.build_outlined),
      ('Tenant profile updated', '2 days ago • Tenant', Icons.person_outline),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          children: [
            Expanded(child: Text('Activity', style: t.textTheme.titleMedium)),
            TextButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demo: filter activity')),
                );
              },
              icon: const Icon(Icons.filter_list_outlined),
              label: const Text('Filter'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...feed.map((a) => Card(
              child: ListTile(
                leading: Icon(a.$3),
                title: Text(a.$1),
                subtitle: Text(a.$2),
              ),
            )),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.bolt_outlined),
            title: const Text('Next: real event stream'),
            subtitle: const Text('Business events from Rent/Tickets/Docs into one timeline'),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
