import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/state/providers.dart';
import '../../ui/widgets/async_value_view.dart';

class MaintenanceInboxScreen extends ConsumerStatefulWidget {
  const MaintenanceInboxScreen({super.key});

  @override
  ConsumerState<MaintenanceInboxScreen> createState() => _MaintenanceInboxScreenState();
}

class _MaintenanceInboxScreenState extends ConsumerState<MaintenanceInboxScreen> {
  String priority = 'All';

  @override
  Widget build(BuildContext context) {
    final tickets = ref.watch(ticketsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('L-30 • Maintenance Inbox')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text('Priority:  '),
                DropdownButton<String>(
                  value: priority,
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'High', child: Text('High')),
                    DropdownMenuItem(value: 'Med', child: Text('Med')),
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                  ],
                  onChanged: (v) => setState(() => priority = v ?? 'All'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: AsyncValueView(
              value: tickets,
              builder: (items) {
                final list = items.where((t) => priority == 'All' ? true : t.priority == priority).toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final t = list[i];
                    return ListTile(
                      leading: CircleAvatar(child: Text(t.priority[0])),
                      title: Text('${t.title} • ${t.unit}'),
                      subtitle: Text('${t.status} • ${DateFormat.yMMMd().format(t.createdAt)}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, '/L-31'),
                    );
                  },
                );
              },
              emptyMessage: 'No maintenance tickets yet.',
            ),
          ),
        ],
      ),
    );
  }
}
