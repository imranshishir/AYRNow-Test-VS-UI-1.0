import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum _EntryStatus { approved, denied, expired }

class _LogEntry {
  final String visitor;
  final String unit;
  final String time;
  final _EntryStatus status;

  const _LogEntry(this.visitor, this.unit, this.time, this.status);
}

const _mockEntries = [
  _LogEntry('Contractor Mike', '2B', '9:15 AM', _EntryStatus.approved),
  _LogEntry('Jane Smith', '5A', '10:30 AM', _EntryStatus.approved),
  _LogEntry('Delivery – FedEx', '1C', '11:00 AM', _EntryStatus.denied),
  _LogEntry('HVAC Tech', '3D', '1:45 PM', _EntryStatus.approved),
  _LogEntry('Unknown Visitor', '4A', '2:30 PM', _EntryStatus.expired),
  _LogEntry('Electrician Paul', '6B', '3:00 PM', _EntryStatus.approved),
];

IconData _statusIcon(_EntryStatus s) {
  switch (s) {
    case _EntryStatus.approved:
      return Icons.check_circle;
    case _EntryStatus.denied:
      return Icons.cancel;
    case _EntryStatus.expired:
      return Icons.timer_off;
  }
}

Color _statusColor(_EntryStatus s) {
  switch (s) {
    case _EntryStatus.approved:
      return Colors.green;
    case _EntryStatus.denied:
      return Colors.red;
    case _EntryStatus.expired:
      return Colors.grey;
  }
}

String _statusLabel(_EntryStatus s) {
  switch (s) {
    case _EntryStatus.approved:
      return 'Approved';
    case _EntryStatus.denied:
      return 'Denied';
    case _EntryStatus.expired:
      return 'Expired';
  }
}

class EntryLogScreen extends ConsumerStatefulWidget {
  const EntryLogScreen({super.key});

  @override
  ConsumerState<EntryLogScreen> createState() => _EntryLogScreenState();
}

class _EntryLogScreenState extends ConsumerState<EntryLogScreen> {
  String _dateFilter = 'Today';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('S-20 • Entry Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export Log',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Log exported (demo).')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Today', label: Text('Today')),
                ButtonSegment(value: 'Yesterday', label: Text('Yesterday')),
                ButtonSegment(value: 'This Week', label: Text('This Week')),
              ],
              selected: {_dateFilter},
              onSelectionChanged: (v) =>
                  setState(() => _dateFilter = v.first),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _mockEntries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, i) {
                final e = _mockEntries[i];
                return Card(
                  child: ListTile(
                    leading: Icon(_statusIcon(e.status),
                        color: _statusColor(e.status)),
                    title: Text(e.visitor),
                    subtitle: Text('Unit ${e.unit} • ${e.time}'),
                    trailing: Chip(
                      label: Text(
                        _statusLabel(e.status),
                        style:
                            TextStyle(color: _statusColor(e.status)),
                      ),
                      side: BorderSide(color: _statusColor(e.status)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
