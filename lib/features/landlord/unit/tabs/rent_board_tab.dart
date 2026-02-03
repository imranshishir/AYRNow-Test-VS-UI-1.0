import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ayrnow/features/landlord/unit/mock_unit_data.dart';

int _moneyToInt(String s) {
  final cleaned = s.replaceAll(RegExp(r'[^0-9]'), '');
  return int.tryParse(cleaned) ?? 0;
}

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
  late final String tenantName = widget.bundle.tenantName;
  late final String unitLabel = widget.bundle.unitName;
  late final int monthlyRent = _moneyToInt(widget.bundle.monthlyRent);
  late final int dueDay = 1;

  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);

  late final List<RentLedgerRow> _ledger =
      widget.bundle.rentLedger.map((r) => r).toList(growable: true);

  final List<_Payment> _payments = [
    _Payment(date: DateTime.now().subtract(const Duration(days: 12)), amount: 1850, method: 'ACH', note: 'On-time'),
    _Payment(date: DateTime.now().subtract(const Duration(days: 45)), amount: 1850, method: 'Card', note: 'Auto-pay'),
  ];

  bool get _isPaidForMonth =>
      _payments.any((p) => p.date.year == _month.year && p.date.month == _month.month);

  String get _monthLabel {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${m[_month.month - 1]} ${_month.year}';
  }

  int _ledgerIndexForMonthLabel(String monthLabel) {
    for (var i = 0; i < _ledger.length; i++) {
      if (_ledger[i].monthLabel == monthLabel) return i;
    }
    return -1;
  }

  RentLedgerRow _rowForMonthLabel(String monthLabel) {
    final idx = _ledgerIndexForMonthLabel(monthLabel);
    if (idx >= 0) return _ledger[idx];

    return RentLedgerRow(
      monthLabel: monthLabel,
      amount: '\$$monthlyRent',
      dueDate: 'Day $dueDay',
      status: RentStatus.due,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final money = NumberFormat.simpleCurrency(locale: 'en_US');

    final row = _rowForMonthLabel(_monthLabel);
    final isPaid = row.status == RentStatus.paid;
    final balanceDue = isPaid ? 0 : _moneyToInt(row.amount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _header(theme),
        const SizedBox(height: 12),

        // Month selector
        Row(
          children: [
            Expanded(
              child: _card(
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: cs.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_monthLabel, style: theme.textTheme.titleMedium),
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
              _statusPill(row.status.label.toUpperCase(), isPaid),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPaid ? 'Rent received for ${row.monthLabel}' : 'Rent due for ${row.monthLabel}',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isPaid
                          ? 'Balance: ${money.format(0)} • Due: ${row.dueDate}'
                          : 'Balance: ${money.format(balanceDue)} • Due: ${row.dueDate}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        FilledButton.icon(
                          onPressed: () => _recordPayment(context, money),
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

        // Rent ledger
        Row(
          children: [
            Text('Rent ledger', style: theme.textTheme.titleMedium),
            const Spacer(),
            Text('${_ledger.length} months', style: theme.textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: 10),

        if (_ledger.isEmpty)
          _emptyCard(
            theme,
            title: 'No ledger entries yet',
            subtitle: 'Ledger rows will appear here when rent periods are created.',
            actionLabel: 'Create period (soon)',
            onTap: () => _toast(context, 'Creating rent periods will be added soon.'),
          )
        else
          ..._ledger.map((r) {
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
                  Icon(
                    r.status == RentStatus.paid
                        ? Icons.check_circle_outline_rounded
                        : (r.status == RentStatus.late ? Icons.error_outline_rounded : Icons.schedule_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${r.monthLabel} • ${r.amount}', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 3),
                        Text('Due: ${r.dueDate} • Status: ${r.status.label}', style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

        const SizedBox(height: 16),

        // Payment history
        Row(
          children: [
            Text('Payment history', style: theme.textTheme.titleMedium),
            const Spacer(),
            Text('${_payments.length} records', style: theme.textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: 10),

        if (_payments.isEmpty)
          _emptyCard(
            theme,
            title: 'No payments recorded yet',
            subtitle: 'Record a payment to track history for this unit.',
            actionLabel: 'Record payment',
            onTap: () => _recordPayment(context, money),
          )
        else
          ..._payments.sortedNewestFirst().map((p) => _historyRow(theme, p, money)),

        const SizedBox(height: 18),

        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Late fees & notes', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              Text(
                'Late fees, notes, and automation rules will be added in an upcoming update.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _toast(context, 'Automation rules will be added soon.'),
                icon: const Icon(Icons.auto_awesome_outlined),
                label: const Text('Set automation (soon)'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _header(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rent', style: theme.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text('$tenantName • $unitLabel', style: theme.textTheme.bodyMedium),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: child,
      ),
    );
  }

  Widget _emptyCard(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(subtitle, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.add_circle_outline),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(String text, bool paid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: paid ? Colors.green.withOpacity(0.12) : Colors.orange.withOpacity(0.12),
      ),
      child: Text(text),
    );
  }

  Future<void> _recordPayment(BuildContext context, NumberFormat money) async {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        final t = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Record payment', style: t.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('This will be connected to payments later. For now it updates local history.',
                  style: t.textTheme.bodyMedium),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _payments.insert(
                      0,
                      _Payment(date: DateTime.now(), amount: monthlyRent, method: 'Manual', note: 'Recorded'),
                    );
                  });
                  _toast(context, 'Payment recorded locally: ${money.format(monthlyRent)}');
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Record now'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendReminder(BuildContext context) {
    _toast(context, 'Reminder sending will be enabled soon.');
  }

  void _openLedger(BuildContext context) {
    _toast(context, 'Ledger detail view will be added soon.');
  }

  Widget _historyRow(ThemeData theme, _Payment p, NumberFormat money) {
    final date = '${p.date.year}-${p.date.month.toString().padLeft(2, '0')}-${p.date.day.toString().padLeft(2, '0')}';
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.receipt_long_outlined),
        title: Text('${money.format(p.amount)} • ${p.method}'),
        subtitle: Text('$date • ${p.note}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            builder: (_) {
              final t = Theme.of(context);
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment details', style: t.textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Text('Amount: ${money.format(p.amount)}'),
                    Text('Method: ${p.method}'),
                    Text('Date: $date'),
                    Text('Note: ${p.note}'),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Payment {
  final DateTime date;
  final int amount;
  final String method;
  final String note;

  const _Payment({
    required this.date,
    required this.amount,
    required this.method,
    required this.note,
  });
}

extension on List<_Payment> {
  List<_Payment> sortedNewestFirst() {
    final copy = [...this];
    copy.sort((a, b) => b.date.compareTo(a.date));
    return copy;
  }
}
