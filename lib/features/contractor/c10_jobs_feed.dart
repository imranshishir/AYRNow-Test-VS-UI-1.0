import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/providers.dart';
import '../../ui/widgets/async_value_view.dart';

class ContractorJobsFeedScreen extends ConsumerWidget {
  const ContractorJobsFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(jobsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('C-10 • Jobs Feed')),
      body: AsyncValueView(
        value: jobs,
        builder: (items) => ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (context, i) {
            final j = items[i];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.work_outline),
                title: Text(j.issue),
                subtitle: Text('${j.property} • ${j.distanceText} • ${j.status}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/C-20'),
              ),
            );
          },
        ),
        emptyMessage: 'No jobs yet. Wait for invites from landlords.',
      ),
    );
  }
}
