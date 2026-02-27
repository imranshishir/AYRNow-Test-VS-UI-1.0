import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReceiptsScreen extends ConsumerStatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  ConsumerState<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends ConsumerState<ReceiptsScreen> {
  String _filter = 'All';

  static const _receipts = <_Receipt>[
    _Receipt(
      id: 'TXN-20260115-001',
      date: 'Jan 15, 2026',
      amount: r'$1,650.00',
      status: 'Paid',
    ),
    _Receipt(
      id: 'TXN-20251215-002',
      date: 'Dec 15, 2025',
      amount: r'$1,650.00',
      status: 'Paid',
    ),
    _Receipt(
      id: 'TXN-20251115-003',
      date: 'Nov 15, 2025',
      amount: r'$1,650.00',
      status: 'Paid',
    ),
    _Receipt(
      id: 'TXN-20251015-004',
      date: 'Oct 15, 2025',
      amount: r'$1,650.00',
      status: 'Pending',
    ),
    _Receipt(
      id: 'TXN-20250915-005',
      date: 'Sep 15, 2025',
      amount: r'$1,650.00',
      status: 'Paid',
    ),
  ];

  List<_Receipt> get _filtered {
    if (_filter == 'All') return _receipts;
    return _receipts.where((r) => r.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('T-14 • Receipts')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                const Text(
                  'Filter:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _filter,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                    DropdownMenuItem(
                      value: 'Pending',
                      child: Text('Pending'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _filter = v!),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final receipt = _filtered[index];
                final isPaid = receipt.status == 'Paid';

                return Card(
                  child: ListTile(
                    leading: Icon(
                      isPaid
                          ? Icons.check_circle_outline
                          : Icons.schedule_outlined,
                      color: isPaid
                          ? colorScheme.primary
                          : colorScheme.error,
                    ),
                    title: Text(receipt.amount),
                    subtitle: Text(receipt.date),
                    trailing: Chip(
                      label: Text(receipt.status),
                      backgroundColor: isPaid
                          ? colorScheme.primaryContainer
                          : colorScheme.errorContainer,
                      labelStyle: TextStyle(
                        color: isPaid
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onErrorContainer,
                      ),
                    ),
                    onTap: () => Navigator.pushNamed(context, '/T-13'),
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

class _Receipt {
  final String id;
  final String date;
  final String amount;
  final String status;

  const _Receipt({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
  });
}
