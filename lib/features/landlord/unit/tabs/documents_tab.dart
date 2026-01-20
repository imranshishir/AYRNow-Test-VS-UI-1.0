import 'package:flutter/material.dart';
import '../mock_unit_data.dart';

class DocumentsTab extends StatelessWidget {
  final UnitBundle bundle;
  const DocumentsTab({super.key, required this.bundle});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final propertyName = bundle.propertyName;
    final unitName = bundle.unitName;

    // Demo docs (until backend + storage)
    final leases = <_DocEntry>[
      _DocEntry(
        title: 'Lease Agreement.pdf',
        subtitle: 'Signed • 2026-01-01',
        icon: Icons.description_outlined,
        category: 'Lease',
        status: 'Signed',
        dateLabel: '2026-01-01',
      ),
      _DocEntry(
        title: 'Move-in Checklist.pdf',
        subtitle: 'Completed • 2026-01-02',
        icon: Icons.checklist_outlined,
        category: 'Lease',
        status: 'Completed',
        dateLabel: '2026-01-02',
      ),
    ];

    final receipts = <_DocEntry>[
      _DocEntry(
        title: 'Payment Receipt - Dec.pdf',
        subtitle: 'Receipt • 2025-12-05',
        icon: Icons.receipt_long_outlined,
        category: 'Receipt',
        status: 'Paid',
        dateLabel: '2025-12-05',
      ),
    ];

    final other = <_DocEntry>[
      _DocEntry(
        title: 'Welcome Letter.pdf',
        subtitle: 'Shared • 2026-01-03',
        icon: Icons.article_outlined,
        category: 'Other',
        status: 'Shared',
        dateLabel: '2026-01-03',
      ),
    ];

    final totalCount = leases.length + receipts.length + other.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          children: [
            Expanded(child: Text('Documents', style: t.textTheme.titleMedium)),
            FilledButton.tonalIcon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Upload coming soon.')),
                );
              },
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Upload'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Documents for $propertyName • $unitName',
          style: t.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        if (totalCount == 0)
          _EmptyState(onUpload: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Upload coming soon.')),
            );
          })
        else ...[
          ..._buildSection(context, title: 'Leases', docs: leases),
          const SizedBox(height: 8),
          ..._buildSection(context, title: 'Receipts', docs: receipts),
          const SizedBox(height: 8),
          ..._buildSection(context, title: 'Other', docs: other),
        ],
      ],
    );
  }

  List<Widget> _buildSection(
    BuildContext context, {
    required String title,
    required List<_DocEntry> docs,
  }) {
    final t = Theme.of(context);
    final section = <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 6),
        child: Text(title, style: t.textTheme.titleSmall),
      ),
    ];

    if (docs.isEmpty) {
      section.add(
        Card(
          child: ListTile(
            leading: const Icon(Icons.folder_open_outlined),
            title: Text('No $title yet'),
            subtitle: const Text('Upload will appear here once available.'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Upload coming soon.')),
              );
            },
          ),
        ),
      );
    } else {
      section.addAll(
        docs.map(
          (d) => Card(
            child: ListTile(
              leading: Icon(d.icon),
              title: Text(d.title),
              subtitle: Text(d.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openDocument(context, d),
            ),
          ),
        ),
      );
    }

    return section;
  }

  void _openDocument(BuildContext context, _DocEntry doc) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        final t = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doc.title, style: t.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text('${doc.category} • ${doc.status}', style: t.textTheme.bodyMedium),
              const SizedBox(height: 6),
              Text('Updated ${doc.dateLabel}', style: t.textTheme.bodySmall),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share coming soon.')),
                  );
                },
                icon: const Icon(Icons.share_outlined),
                label: const Text('Share'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Download coming soon.')),
                  );
                },
                icon: const Icon(Icons.download_outlined),
                label: const Text('Download'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DocEntry {
  final String title;
  final String subtitle;
  final IconData icon;
  final String category;
  final String status;
  final String dateLabel;

  const _DocEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.category,
    required this.status,
    required this.dateLabel,
  });
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onUpload;
  const _EmptyState({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No documents yet', style: t.textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(
              'Upload leases, receipts, and other files to keep this unit organized.',
              style: t.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Upload (coming soon)'),
            ),
          ],
        ),
      ),
    );
  }
}
