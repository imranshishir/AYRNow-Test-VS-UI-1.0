import 'package:flutter/material.dart';
import '../mock_unit_data.dart';

class RentBoardTab extends StatefulWidget {
  final UnitBundle bundle;
  const RentBoardTab({super.key, required this.bundle});

  @override
  State<RentBoardTab> createState() => _RentBoardTabState();
}

class _RentBoardTabState extends State<RentBoardTab> {
  late List<RentLedgerRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = List.of(widget.bundle.rentLedger);
  }

  void _markPaid(int i) {
    setState(() {
      _rows[i] = _rows[i].copyWith(status: RentStatus.paid);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as paid')));
  }

  void _sendReminder(int i) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder sent for ${_rows[i].monthLabel} (demo)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rent summary', style: t.textTheme.titleMedium),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _Metric(label: 'Monthly rent', value: widget.bundle.monthlyRent)),
                    const SizedBox(width: 12),
                    Expanded(child: _Metric(label: 'Current balance', value: widget.bundle.currentBalance)),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Demo: Collect rent flow')),
                    );
                  },
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Collect rent'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('Ledger', style: t.textTheme.titleMedium),
        const SizedBox(height: 10),
        ...List.generate(_rows.length, (i) {
          final r = _rows[i];
          return Card(
            child: ListTile(
              leading: Icon(r.status == RentStatus.paid ? Icons.check_circle : Icons.schedule),
              title: Text('${r.monthLabel} • ${r.amount}'),
              subtitle: Text('Due: ${r.dueDate} • Status: ${r.status.label}'),
              trailing: Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => _sendReminder(i),
                    child: const Text('Reminder'),
                  ),
                  if (r.status != RentStatus.paid)
                    FilledButton.tonal(
                      onPressed: () => _markPaid(i),
                      child: const Text('Mark paid'),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: t.textTheme.labelMedium),
          const SizedBox(height: 6),
          Text(value, style: t.textTheme.titleMedium),
        ],
      ),
    );
  }
}
