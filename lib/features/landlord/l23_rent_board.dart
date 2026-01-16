import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/state/providers.dart';
import '../../ui/widgets/async_value_view.dart';

class RentBoardScreen extends ConsumerStatefulWidget {
  const RentBoardScreen({super.key});

  @override
  ConsumerState<RentBoardScreen> createState() => _RentBoardScreenState();
}

class _RentBoardScreenState extends ConsumerState<RentBoardScreen> {
  String statusFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final rent = ref.watch(rentBoardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('L-23 • Rent Status Board'),
        actions: [
          IconButton(
            onPressed: () => setState(() => statusFilter = 'All'),
            icon: const Icon(Icons.filter_alt_off_outlined),
            tooltip: 'Clear filter',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text('Status:  '),
                DropdownButton<String>(
                  value: statusFilter,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                    DropdownMenuItem(value: 'Late', child: Text('Late')),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'Partial', child: Text('Partial')),
                    DropdownMenuItem(value: 'Manual', child: Text('Manual')),
                  ],
                  onChanged: (v) => setState(() => statusFilter = v ?? 'All'),
                ),
                const Spacer(),
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.pushNamed(context, '/L-28'),
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Export'),
                )
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: AsyncValueView(
              value: rent,
              builder: (items) {
                final list = items.where((e) => statusFilter == 'All' ? true : e.status == statusFilter).toList();
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final r = list[i];
                    return ListTile(
                      title: Text('${r.tenantName} • ${r.unit}'),
                      subtitle: Text('Due ${DateFormat.yMMMd().format(r.dueDate)} • \$${r.amountDue.toStringAsFixed(0)}'),
                      trailing: Chip(label: Text(r.status)),
                      onTap: () => Navigator.pushNamed(context, '/L-24'),
                    );
                  },
                );
              },
              emptyMessage: 'No tenants yet. Add a property and invite tenants.',
            ),
          ),
        ],
      ),
    );
  }
}
