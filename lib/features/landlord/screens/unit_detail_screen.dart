import 'package:flutter/material.dart';

/// Minimal unit detail screen with Residents & Family entry.
/// Reached from rent board when tapping a row.
class UnitDetailScreen extends StatelessWidget {
  final String? unitLabel;

  const UnitDetailScreen({super.key, this.unitLabel});

  @override
  Widget build(BuildContext context) {
    final label = unitLabel ?? 'Unit';
    return Scaffold(
      appBar: AppBar(title: Text('L-24 • $label')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.people_outlined),
              title: const Text('Residents & Family'),
              subtitle: const Text('View residents and invite members'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/L-50'),
            ),
          ),
        ],
      ),
    );
  }
}
