import 'package:flutter/material.dart';
import 'package:ayrnow/features/tenant/screens/t_models.dart';

class TenantPropertyUnitsScreen extends StatelessWidget {
  final TenantProperty property;
  const TenantPropertyUnitsScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(property.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(property.address, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          ...property.units.map((u) => _UnitTile(property: property, unit: u)),
        ],
      ),
    );
  }
}

class _UnitTile extends StatelessWidget {
  final TenantProperty property;
  final TenantUnit unit;
  const _UnitTile({required this.property, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.door_front_door_outlined),
        title: Text(unit.label),
        subtitle: Text('${money(unit.rentCents)} • ${unit.dueDateLabel}'),
        trailing: unit.isOverdue
            ? Chip(
                label: const Text('Overdue'),
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
              )
            : const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => TenantUnitRentDetailScreen(property: property, unit: unit)),
          );
        },
      ),
    );
  }
}

class TenantUnitRentDetailScreen extends StatelessWidget {
  final TenantProperty property;
  final TenantUnit unit;
  const TenantUnitRentDetailScreen({super.key, required this.property, required this.unit});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(unit.label)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(property.address, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Kpi(label: 'Rent', value: money(unit.rentCents)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Kpi(label: 'Due', value: unit.dueDateLabel),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: unit.isOverdue ? cs.errorContainer : cs.secondaryContainer,
                    ),
                    child: Row(
                      children: [
                        Icon(unit.isOverdue ? Icons.warning_amber : Icons.check_circle_outline,
                            color: unit.isOverdue ? cs.onErrorContainer : cs.onSecondaryContainer),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            unit.isOverdue ? 'Payment is overdue. Pay now to avoid fees.' : 'Next payment is scheduled.',
                            style: TextStyle(
                              color: unit.isOverdue ? cs.onErrorContainer : cs.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Rent Ledger (demo)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _LedgerRow(label: 'December', value: money(unit.rentCents), status: 'Paid'),
          _LedgerRow(label: 'January', value: money(unit.rentCents), status: unit.isOverdue ? 'Overdue' : 'Due'),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => TenantPayRentScreen(property: property, unit: unit)),
              );
            },
            icon: const Icon(Icons.payments),
            label: Text('Pay ${money(unit.rentCents)}'),
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  final String label;
  final String value;
  const _Kpi({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  final String label;
  final String value;
  final String status;
  const _LedgerRow({required this.label, required this.value, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(value, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(width: 10),
            Chip(label: Text(status)),
          ],
        ),
      ),
    );
  }
}

class TenantPayRentScreen extends StatefulWidget {
  final TenantProperty property;
  final TenantUnit unit;
  const TenantPayRentScreen({super.key, required this.property, required this.unit});

  @override
  State<TenantPayRentScreen> createState() => _TenantPayRentScreenState();
}

class _TenantPayRentScreenState extends State<TenantPayRentScreen> {
  String _method = 'Bank (ACH)';
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final amount = money(widget.unit.rentCents);

    return Scaffold(
      appBar: AppBar(title: const Text('Pay Rent')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.property.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(widget.unit.label, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  Text('Amount', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 6),
                  Text(amount, style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text('Payment method', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _method,
            onChanged: (v) => setState(() => _method = v ?? _method),
            items: const [
              DropdownMenuItem(value: 'Bank (ACH)', child: Text('Bank (ACH)')),
              DropdownMenuItem(value: 'Debit Card', child: Text('Debit Card')),
              DropdownMenuItem(value: 'Credit Card', child: Text('Credit Card')),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              hintText: 'January rent',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _saving
                ? null
                : () async {
                    setState(() => _saving = true);
                    await Future<void>.delayed(const Duration(milliseconds: 900));
                    if (!mounted) return;
                    setState(() => _saving = false);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => TenantReceiptScreen(
                          title: 'Rent Payment Successful',
                          subtitle: '$amount via $_method',
                          reference: 'AYR-${DateTime.now().millisecondsSinceEpoch}',
                        ),
                      ),
                    );
                  },
            icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator()) : const Icon(Icons.lock),
            label: Text(_saving ? 'Processing...' : 'Confirm & Pay'),
          ),
          const SizedBox(height: 10),
          Text(
            'Demo only: no real payment is processed.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class TenantReceiptScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String reference;

  const TenantReceiptScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.reference,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipt')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, size: 44),
                  const SizedBox(height: 10),
                  Text(title, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(subtitle, textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  Text('Reference: $reference', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to unit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
