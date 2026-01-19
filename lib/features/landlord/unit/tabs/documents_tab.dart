import 'package:flutter/material.dart';
import '../mock_unit_data.dart';

class DocumentsTab extends StatelessWidget {
  final UnitBundle bundle;
  const DocumentsTab({super.key, required this.bundle});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    // Demo docs (until backend + storage)
    final docs = [
      ('Lease Agreement.pdf', 'Signed • 2026-01-01', Icons.description_outlined),
      ('Move-in Checklist.pdf', 'Completed • 2026-01-02', Icons.checklist_outlined),
      ('Payment Receipt - Dec.pdf', 'Receipt • 2025-12-05', Icons.receipt_long_outlined),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          children: [
            Expanded(child: Text('Documents', style: t.textTheme.titleMedium)),
            FilledButton.tonalIcon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demo: upload document')),
                );
              },
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Upload'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...docs.map((d) => Card(
              child: ListTile(
                leading: Icon(d.$3),
                title: Text(d.$1),
                subtitle: Text(d.$2),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Demo: open "${d.$1}"')),
                  );
                },
              ),
            )),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text('Storage & permissions (next)'),
            subtitle: const Text('S3/Cloud Storage + role-based access per unit'),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
