import 'package:flutter/material.dart';
import 'package:ayrnow/features/landlord/screens/landlord_demo_store.dart';

class LandlordContractorsScreen extends StatefulWidget {
  final LandlordDemoStore store;
  const LandlordContractorsScreen({super.key, required this.store});

  @override
  State<LandlordContractorsScreen> createState() =>
      _LandlordContractorsScreenState();
}

class _LandlordContractorsScreenState extends State<LandlordContractorsScreen> {
  String _tab = 'Directory';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contractors & Work Orders')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                  value: 'Directory',
                  label: Text('Directory'),
                  icon: Icon(Icons.groups_outlined)),
              ButtonSegment(
                  value: 'WorkOrders',
                  label: Text('Work Orders'),
                  icon: Icon(Icons.receipt_long_outlined)),
            ],
            selected: {_tab},
            onSelectionChanged: (s) => setState(() => _tab = s.first),
          ),
          const SizedBox(height: 12),
          if (_tab == 'Directory')
            _directory(context)
          else
            _workOrders(context),
        ],
      ),
    );
  }

  Widget _directory(BuildContext context) {
    return Column(
      children: widget.store.contractors.map((c) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.handyman_outlined)),
            title: Text(c.name),
            subtitle: Text(
                '${c.trade} • ${c.phone} • ⭐ ${c.rating.toStringAsFixed(1)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Next: Contractor profile + reviews.'))),
          ),
        );
      }).toList(),
    );
  }

  Widget _workOrders(BuildContext context) {
    final list = widget.store.workOrders;
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 24),
        child: Center(
            child: Text(
                'No work orders yet. Assign a contractor from a ticket to create one.')),
      );
    }

    return Column(
      children: list
          .map((w) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (_) =>
                              _WorkOrderDetail(store: widget.store, wo: w)))
                      .then((_) => setState(() {})),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                                child: Text('WO • ${w.id}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall)),
                            _pill(context, w.status),
                          ]),
                          const SizedBox(height: 6),
                          Text(
                              '${w.contractorName} • ${w.propertyName} • ${w.unitLabel}'),
                          const SizedBox(height: 6),
                          Text('Scheduled: ${w.scheduled}'),
                          if (w.invoiceAmount != null &&
                              w.invoiceAmount! > 0) ...[
                            const SizedBox(height: 6),
                            Text(
                                'Invoice: \$${w.invoiceAmount!.toStringAsFixed(0)}'),
                          ],
                        ]),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _pill(BuildContext context, String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Text(t),
    );
  }
}

class _WorkOrderDetail extends StatelessWidget {
  final LandlordDemoStore store;
  final WorkOrder wo;
  const _WorkOrderDetail({required this.store, required this.wo});

  @override
  Widget build(BuildContext context) {
    final w =
        store.workOrders.firstWhere((x) => x.id == wo.id, orElse: () => wo);

    return Scaffold(
      appBar: AppBar(title: const Text('Work Order')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WO • ${w.id}',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(w.contractorName),
                    const SizedBox(height: 6),
                    Text('${w.propertyName} • ${w.unitLabel}'),
                    const SizedBox(height: 10),
                    Text('Status: ${w.status}'),
                    const SizedBox(height: 6),
                    Text('Scheduled: ${w.scheduled}'),
                    if (w.invoiceAmount != null) ...[
                      const SizedBox(height: 6),
                      Text('Invoice: \$${w.invoiceAmount!.toStringAsFixed(0)}'),
                    ],
                  ]),
            ),
          ),
          const SizedBox(height: 12),
          if (w.status == 'In progress' || w.status == 'Scheduled')
            FilledButton.icon(
              onPressed: () {
                store.completeWorkOrder(w.id, invoiceAmount: 275);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text('Marked complete (demo). Invoice submitted.')));
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.task_alt),
              label: const Text('Mark complete + submit invoice'),
            )
          else if (w.status == 'Needs approval')
            FilledButton.icon(
              onPressed: () {
                store.approveInvoice(w.id);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invoice approved (demo).')));
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.verified_outlined),
              label: const Text('Approve invoice'),
            )
          else
            OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Approved. Next: payout + accounting.'))),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Approved'),
            ),
        ],
      ),
    );
  }
}
