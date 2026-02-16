import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ayrnow/features/guard/screens/guard_demo_data.dart';

class GuardIncidentReportScreen extends StatefulWidget {
  final GuardDemoStore store;
  final String? presetProperty;
  final String? presetUnit;

  const GuardIncidentReportScreen({
    super.key,
    required this.store,
    this.presetProperty,
    this.presetUnit,
  });

  @override
  State<GuardIncidentReportScreen> createState() =>
      _GuardIncidentReportScreenState();
}

class _GuardIncidentReportScreenState extends State<GuardIncidentReportScreen> {
  final _desc = TextEditingController();
  final _property = TextEditingController();
  final _unit = TextEditingController();
  String _category = 'Trespassing';

  @override
  void initState() {
    super.initState();
    _property.text = widget.presetProperty ?? 'Harlem Gardens';
    _unit.text = widget.presetUnit ?? 'Lobby';
  }

  @override
  void dispose() {
    _desc.dispose();
    _property.dispose();
    _unit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d, h:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text('Incident Reports')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create report',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _category,
                    onChanged: (v) =>
                        setState(() => _category = v ?? _category),
                    items: const [
                      DropdownMenuItem(
                          value: 'Trespassing', child: Text('Trespassing')),
                      DropdownMenuItem(
                          value: 'Noise / Disturbance',
                          child: Text('Noise / Disturbance')),
                      DropdownMenuItem(
                          value: 'Property Damage',
                          child: Text('Property Damage')),
                      DropdownMenuItem(
                          value: 'Injury / Medical',
                          child: Text('Injury / Medical')),
                      DropdownMenuItem(
                          value: 'Suspicious Activity',
                          child: Text('Suspicious Activity')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _property,
                    decoration: const InputDecoration(
                      labelText: 'Property',
                      prefixIcon: Icon(Icons.apartment_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _unit,
                    decoration: const InputDecoration(
                      labelText: 'Location / Unit',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _desc,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    icon: const Icon(Icons.save_outlined),
                    onPressed: () {
                      final p = _property.text.trim();
                      final u = _unit.text.trim();
                      final d = _desc.text.trim();
                      if (p.isEmpty || u.isEmpty || d.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please fill Property, Location, and Description.')),
                        );
                        return;
                      }
                      widget.store.addIncident(
                        propertyName: p,
                        unitLabel: u,
                        category: _category,
                        description: d,
                      );
                      _desc.clear();
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Incident saved (demo).')),
                      );
                    },
                    label: const Text('Save report'),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Demo: Photos/attachments + notifying landlord/PM can be added later.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('History', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          if (widget.store.incidents.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Text('No incident reports yet.',
                  style: Theme.of(context).textTheme.bodyMedium),
            )
          else
            ...widget.store.incidents.map((r) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(r.category,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium)),
                            Text(fmt.format(r.createdAt),
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${r.propertyName} • ${r.unitLabel}'),
                        const SizedBox(height: 8),
                        Text(r.description),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
