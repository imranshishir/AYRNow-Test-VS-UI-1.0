import 'package:flutter/material.dart';
import '../mock_unit_data.dart';

class ContractorsTab extends StatelessWidget {
  final UnitBundle bundle;
  const ContractorsTab({super.key, required this.bundle});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text('Preferred contractors', style: t.textTheme.titleMedium),
        const SizedBox(height: 10),
        ...bundle.contractors.map((c) => Card(
              child: ListTile(
                leading: const Icon(Icons.handyman_outlined),
                title: Text(c.name),
                subtitle: Text('${c.trade} • Rating ${c.rating}'),
                trailing: FilledButton.tonal(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Demo: assign ${c.name}')),
                    );
                  },
                  child: const Text('Assign'),
                ),
              ),
            )),
        const SizedBox(height: 14),
        Text('Assignment history (demo)', style: t.textTheme.titleMedium),
        const SizedBox(height: 10),
        ...bundle.assignmentHistory.map((h) => Card(
              child: ListTile(
                leading: const Icon(Icons.history),
                title: Text(h.title),
                subtitle: Text('${h.contractor} • ${h.date} • ${h.status}'),
              ),
            )),
      ],
    );
  }
}
