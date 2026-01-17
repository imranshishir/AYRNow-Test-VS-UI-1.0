import 'package:flutter/material.dart';
import 'package:ayrnow/features/landlord/screens/landlord_demo_store.dart';

class LandlordRentScreen extends StatefulWidget {
  final LandlordDemoStore store;
  const LandlordRentScreen({super.key, required this.store});

  @override
  State<LandlordRentScreen> createState() => _LandlordRentScreenState();
}

class _LandlordRentScreenState extends State<LandlordRentScreen> {
  String _q = '';
  String _status = 'All';

  @override
  Widget build(BuildContext context) {
    final list = widget.store.rent.where((r) {
      final query = _q.trim().toLowerCase();
      final matchesQ = query.isEmpty ||
          r.propertyName.toLowerCase().contains(query) ||
          r.unitLabel.toLowerCase().contains(query) ||
          r.tenantName.toLowerCase().contains(query) ||
          r.id.toLowerCase().contains(query);
      final matchesStatus = _status == 'All' || r.status == _status;
      return matchesQ && matchesStatus;
    }).toList();

    final totalDue = list
        .where((r) => r.status != 'Paid')
        .fold<double>(0, (p, e) => p + e.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Rent & Ledger')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          _summary(context, totalDue),
          const SizedBox(height: 12),
          _filters(context),
          const SizedBox(height: 12),
          ...list.map((r) => _rentCard(context, r)),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 36),
              child: Center(
                  child: Text('No rent items match your filter.',
                      style: Theme.of(context).textTheme.bodyMedium)),
            ),
        ],
      ),
    );
  }

  Widget _summary(BuildContext context, double totalDue) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Icon(Icons.payments_outlined,
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Month snapshot',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text('Total outstanding: \$${totalDue.toStringAsFixed(0)}'),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filters(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Search / Filter',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 10),
          TextField(
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search tenant, unit, property…'),
            onChanged: (v) => setState(() => _q = v),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _status,
            onChanged: (v) => setState(() => _status = v ?? 'All'),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All statuses')),
              DropdownMenuItem(value: 'Due', child: Text('Due')),
              DropdownMenuItem(value: 'Late', child: Text('Late')),
              DropdownMenuItem(value: 'Paid', child: Text('Paid')),
              DropdownMenuItem(value: 'Partial', child: Text('Partial')),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _rentCard(BuildContext context, RentLineItem r) {
    final isPaid = r.status == 'Paid';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Expanded(
                  child: Text('${r.unitLabel} • ${r.propertyName}',
                      style: Theme.of(context).textTheme.titleSmall)),
              _statusChip(context, r.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(r.tenantName),
          const SizedBox(height: 6),
          Text('${r.monthLabel} • \$${r.amount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isPaid
                      ? null
                      : () {
                          widget.store.sendReminder(r.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Reminder sent (demo).')));
                        },
                  icon: const Icon(Icons.notifications_none),
                  label: const Text('Reminder'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isPaid
                      ? null
                      : () {
                          widget.store.markRentPaid(r.id);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Marked Paid (demo).')));
                        },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Mark Paid'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Receipt view + payments integration comes next.',
              style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
    );
  }

  Widget _statusChip(BuildContext context, String s) {
    final cs = Theme.of(context).colorScheme;
    final bg = switch (s) {
      'Paid' => cs.primaryContainer,
      'Late' => cs.errorContainer,
      _ => cs.tertiaryContainer,
    };
    final fg = switch (s) {
      'Paid' => cs.onPrimaryContainer,
      'Late' => cs.onErrorContainer,
      _ => cs.onTertiaryContainer,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(999), color: bg),
      child: Text(s, style: TextStyle(color: fg)),
    );
  }
}
