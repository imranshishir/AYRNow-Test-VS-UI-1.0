import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ayrnow/features/guard/screens/guard_demo_data.dart';
import 'package:ayrnow/features/guard/screens/guard_incident_report_screen.dart';

class GuardActiveVisitorsScreen extends StatefulWidget {
  final GuardDemoStore store;
  const GuardActiveVisitorsScreen({super.key, required this.store});

  @override
  State<GuardActiveVisitorsScreen> createState() =>
      _GuardActiveVisitorsScreenState();
}

class _GuardActiveVisitorsScreenState extends State<GuardActiveVisitorsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('h:mm a');
    final list = widget.store.active.where((v) {
      final q = _query.trim().toLowerCase();
      return q.isEmpty ||
          v.visitorName.toLowerCase().contains(q) ||
          v.unitLabel.toLowerCase().contains(q) ||
          v.propertyName.toLowerCase().contains(q) ||
          v.passCode.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Visitors'),
        actions: [
          IconButton(
            tooltip: 'Report incident',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      GuardIncidentReportScreen(store: widget.store),
                ),
              );
            },
            icon: const Icon(Icons.report_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search active visitors…',
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 12),
          if (list.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    const Icon(Icons.people_outline, size: 48),
                    const SizedBox(height: 12),
                    Text('No active visitors',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      'After you check-in a visitor from Approvals,\n'
                      'they show up here until you check them out.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...list.map((v) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(v.visitorName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium)),
                            Chip(label: Text(v.passCode)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${v.propertyName} • ${v.unitLabel}'),
                        const SizedBox(height: 6),
                        Text(
                            'Checked-in: ${fmt.format(v.checkInAt)} • Party: ${v.partySize}'
                            '${v.vehiclePlate == null ? '' : ' • Plate: ${v.vehiclePlate}'}'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(
                                    Icons.report_gmailerrorred_outlined),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => GuardIncidentReportScreen(
                                        store: widget.store,
                                        presetProperty: v.propertyName,
                                        presetUnit: v.unitLabel,
                                      ),
                                    ),
                                  );
                                },
                                label: const Text('Incident'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                icon: const Icon(Icons.logout),
                                onPressed: () {
                                  widget.store.checkOut(v.id);
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Checked-out (demo).')),
                                  );
                                },
                                label: const Text('Check-out'),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
