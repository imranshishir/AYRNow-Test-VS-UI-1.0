import 'package:flutter/material.dart';

class GuardHome extends StatelessWidget {
  const GuardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      children: [
        Text('Approvals Queue', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...[
          ('Guest: John D', 'Unit 12A • 2 visitors', Icons.badge),
          ('Delivery: Amazon', 'Unit 3B • Package', Icons.local_shipping),
          ('Guest: Family', 'Unit 7C • 4 visitors', Icons.groups),
        ].map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Card(
            child: ListTile(
              leading: Icon(a.$3),
              title: Text(a.$1),
              subtitle: Text(a.$2),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Demo: Denied "${a.$1}"')),
                    ),
                    icon: const Icon(Icons.close),
                  ),
                  IconButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Demo: Approved "${a.$1}"')),
                    ),
                    icon: const Icon(Icons.check),
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }
}
