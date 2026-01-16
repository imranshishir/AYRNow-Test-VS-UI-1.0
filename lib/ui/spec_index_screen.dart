import 'package:flutter/material.dart';

class SpecIndexScreen extends StatelessWidget {
  final List<String> ids;
  const SpecIndexScreen({super.key, required this.ids});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Screens (Spec Index)'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: ids.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final id = ids[i];
          return ListTile(
            title: Text(id),
            subtitle: const Text('Open screen'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/$id'),
          );
        },
      ),
    );
  }
}
