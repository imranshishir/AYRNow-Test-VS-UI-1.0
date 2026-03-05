import 'package:flutter/material.dart';

/// Minimal unit detail screen with Residents & Family entry.
/// Reached from rent board or property detail when tapping a row.
class UnitDetailScreen extends StatelessWidget {
  final String? unitId;
  final String? unitLabel;

  const UnitDetailScreen({super.key, this.unitId, this.unitLabel});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final id = unitId ?? (args is Map ? args['unitId']?.toString() : null);
    final label = unitLabel ?? (args is Map ? args['unitLabel']?.toString() : null) ?? 'Unit';
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
              onTap: id == null || id.isEmpty
                  ? null
                  : () {
                      Navigator.pushNamed(
                        context,
                        '/L-50',
                        arguments: {'unitId': id, 'unitLabel': label},
                      );
                    },
            ),
          ),
        ],
      ),
    );
  }
}
