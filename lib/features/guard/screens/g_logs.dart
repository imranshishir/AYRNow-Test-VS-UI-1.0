import 'package:flutter/material.dart';
import 'package:ayrnow/features/guard/screens/g_models.dart';

class GuardLogsScreen extends StatelessWidget {
  const GuardLogsScreen({super.key});

  static const logs = <GuardLogEntry>[
    GuardLogEntry(
        time: '08:12 AM',
        title: 'Approved • Harlem Heights Apt 2B',
        subtitle: 'Guest: John Smith'),
    GuardLogEntry(
        time: '08:25 AM',
        title: 'Denied • Harlem Heights Apt 1A',
        subtitle: 'Guest: Unknown Visitor'),
    GuardLogEntry(
        time: '10:03 AM',
        title: 'Approved • Elmwood Plaza Store 12',
        subtitle: 'Delivery: UPS'),
    GuardLogEntry(
        time: '02:41 PM',
        title: 'Approved • Lakeview Villas Apt 03',
        subtitle: 'Contractor: HVAC Tech'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      children: [
        Row(
          children: [
            Expanded(
                child: Text('Logs',
                    style: Theme.of(context).textTheme.titleLarge)),
            FilledButton.tonalIcon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Next: search + export logs')),
              ),
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final l = logs[i];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(l.title),
                subtitle: Text(l.subtitle),
                trailing: Text(l.time,
                    style: Theme.of(context).textTheme.labelMedium),
              );
            },
          ),
        ),
      ],
    );
  }
}
