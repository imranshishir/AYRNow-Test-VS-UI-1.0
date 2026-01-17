import 'package:flutter/material.dart';
import 'package:ayrnow/features/landlord/unit/mock_unit_data.dart';

class RentBoardTab extends StatefulWidget {
  final UnitBundle bundle;

  const RentBoardTab({
    super.key,
    required this.bundle,
  });

  @override
  State<RentBoardTab> createState() => _RentBoardTabState();
}

class _RentBoardTabState extends State<RentBoardTab> {
  // Mock unit + tenant (replace with store later)
  late final String tenantName = 'Alex Tenant';
  late final String unitLabel = widget.bundle.unitId;
  late final int monthlyRent = 1850;
  late final int dueDay = 1;

  // Mock state
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  final List<_Payment> _payments = [
    _Payment(date: DateTime.now().subtract(const Duration(days: 12)), amount: 1850, method: 'ACH', note: 'On-time'),
    _Payment(date: DateTime.now().subtract(const Duration(days: 45)), amount: 1850, method: 'Card', note: 'Auto-pay'),
  ];

  bool get _isPaidForMonth {
    return _payments.any((p) => p.date.year == _month.year && p.date.month == _month.month);
  }

  String get _monthLabel {
    const m = [
      'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${m[_month.month - 1]} ${_month.year}';
  }

  int get _balanceDue => _isPaidForMonth ? 0 : monthlyRent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _header(theme),
        const SizedBox(height: 12),

        // Month selector + status
        Row(
          children: [
            Expanded(
              child: _card(
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: cs.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _monthLabel,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Previous month',
                      onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1, 1)),
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    IconButton(
                      tooltip: 'Next month',
                      onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1, 1)),
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Status card
        _card(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _statusPill(_isPaidForMonth ? 'PAID' : 'DUE', _isPaidForMonth),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isPaidForMonth ? 'Rent received for $_monthLabel' : 'Rent due for $_monthLabel',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isPaidForMonth
                          ? 'Balance: \$0 • Due day: $dueDay'
                          : 'Balance: \$$_balanceDue • Due day: $dueDay',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: () => _recordPayment(context),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Record payment'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _sendReminder(context),
                          icon: const Icon(Icons.notifications_active_outlined),
                          label: const Text('Send reminder'),
                        ),
                        TextButton.icon(
                          onPressed: () => _openLedger(context),
                          icon: const Icon(Icons.receipt_long_rounded),
                          label: const Text('View ledger'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Payment history (mock)
        Row(
          children: [
            Text('Payment history', style: theme.textTheme.titleMedium),
            const Spacer(),
            Text('${_payments.length} records', style: theme.textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: 10),

        ..._payments
            .sortedNewestFirst()
            .map((p) => _historyRow(theme, p))
            .toList(),

        const SizedBox(height: 18),

        // Quick “Late fees / notes” placeholder (HIFI skeleton)
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notes', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(
                'Mock logic: late fees + grace period + auto-pay rules can be added here.\n'
                'Next: connect to LandlordDemoStore + Tenant profile + real Rent ledger model.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header(ThemeData theme) {
    return Row(
      children: [
        const Icon(Icons.home_work_rounded),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Unit $unitLabel', style: theme.textTheme.titleLarge),
              const SizedBox(height: 2),
              Text('Tenant: $tenantName', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusPill(String text, bool ok) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: ok ? cs.primaryContainer : cs.tertiaryContainer,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: ok ? cs.onPrimaryContainer : cs.onTertiaryContainer,
              letterSpacing: 0.6,
            ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: child,
    );
  }

  Widget _historyRow(ThemeData theme, _Payment p) {
    final date = '${p.date.month}/${p.date.day}/${p.date.year}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border.all(color: theme.dividerColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\$${p.amount} • ${p.method}', style: theme.textTheme.titleSmall),
                const SizedBox(height: 3),
                Text(date + (p.note.isEmpty ? '' : ' • ${p.note}'), style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Details',
            onPressed: () => _paymentDetails(context, p),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }

  Future<void> _recordPayment(BuildContext context) async {
    final amountCtrl = TextEditingController(text: monthlyRent.toString());
    final noteCtrl = TextEditingController(text: _isPaidForMonth ? 'Extra / partial' : 'Recorded manually');
    String method = 'ACH';

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final media = MediaQuery.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: media.viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Record payment', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: method,
                items: const [
                  DropdownMenuItem(value: 'ACH', child: Text('ACH')),
                  DropdownMenuItem(value: 'Card', child: Text('Card')),
                  DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'Check', child: Text('Check')),
                ],
                onChanged: (v) => method = v ?? 'ACH',
                decoration: const InputDecoration(labelText: 'Method'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );

    if (ok == true) {
      final amt = int.tryParse(amountCtrl.text.trim()) ?? monthlyRent;
      setState(() {
        _payments.add(_Payment(
          date: DateTime(_month.year, _month.month, dueDay),
          amount: amt,
          method: method,
          note: noteCtrl.text.trim(),
        ));
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment recorded (mock)')),
        );
      }
    }
  }

  void _sendReminder(BuildContext context) {
    final msg = _isPaidForMonth
        ? 'Already paid for $_monthLabel (mock reminder not sent)'
        : 'Reminder sent to tenant (mock)';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openLedger(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _LedgerScreen(
          unitLabel: unitLabel,
          tenantName: tenantName,
          monthLabel: _monthLabel,
          monthlyRent: monthlyRent,
          payments: _payments.sortedNewestFirst(),
        ),
      ),
    );
  }

  void _paymentDetails(BuildContext context, _Payment p) {
    final date = '${p.date.month}/${p.date.day}/${p.date.year}';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Payment details'),
        content: Text(
          'Amount: \$${p.amount}\n'
          'Date: $date\n'
          'Method: ${p.method}\n'
          'Note: ${p.note.isEmpty ? '(none)' : p.note}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _LedgerScreen extends StatelessWidget {
  final String unitLabel;
  final String tenantName;
  final String monthLabel;
  final int monthlyRent;
  final List<_Payment> payments;

  const _LedgerScreen({
    required this.unitLabel,
    required this.tenantName,
    required this.monthLabel,
    required this.monthlyRent,
    required this.payments,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('Ledger • Unit $unitLabel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Tenant: $tenantName', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text('Month: $monthLabel • Rent: \$$monthlyRent', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          ...payments.map((p) {
            final date = '${p.date.month}/${p.date.day}/${p.date.year}';
            return ListTile(
              leading: const Icon(Icons.receipt_long_rounded),
              title: Text('\$${p.amount} • ${p.method}'),
              subtitle: Text(date + (p.note.isEmpty ? '' : ' • ${p.note}')),
            );
          }),
        ],
      ),
    );
  }
}

class _Payment {
  final DateTime date;
  final int amount;
  final String method;
  final String note;

  _Payment({
    required this.date,
    required this.amount,
    required this.method,
    required this.note,
  });
}

extension _PaymentSort on List<_Payment> {
  List<_Payment> sortedNewestFirst() {
    final copy = [...this];
    copy.sort((a, b) => b.date.compareTo(a.date));
    return copy;
  }
}
