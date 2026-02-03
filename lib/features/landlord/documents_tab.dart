import 'package:flutter/material.dart';

/// Backend-ready document model (local-friendly).
/// Later: map this to your repository entities + storage provider.
class UnitDocument {
  final String id;
  final String title; // e.g., "Lease - Unit 2B"
  final String type;  // "Lease" | "Receipt" | "Other"
  final DateTime createdAt;
  final int? sizeBytes;

  const UnitDocument({
    required this.id,
    required this.title,
    required this.type,
    required this.createdAt,
    this.sizeBytes,
  });
}

/// Backend-ready repository interface (NO backend yet).
abstract class UnitDocumentsRepository {
  Future<List<UnitDocument>> listForUnit({required String unitId});
}

/// Simple local repo (in-memory). Replace with Riverpod provider later if desired.
class localUnitDocumentsRepository implements UnitDocumentsRepository {
  final Map<String, List<UnitDocument>> _byUnit;
  localUnitDocumentsRepository(this._byUnit);

  @override
  Future<List<UnitDocument>> listForUnit({required String unitId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List<UnitDocument>.unmodifiable(_byUnit[unitId] ?? const []);
  }
}

/// Documents tab used inside UnitTabsScreen.
/// - NO dead ends
/// - App Store-grade empty + loading states
/// - Backend-ready via repository interface
class DocumentsTab extends StatefulWidget {
  final String unitId;

  /// Optional injection for local/testing. If null, uses an empty local repo.
  final UnitDocumentsRepository? repo;

  const DocumentsTab({
    super.key,
    required this.unitId,
    this.repo,
  });

  @override
  State<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<DocumentsTab> {
  late final UnitDocumentsRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = widget.repo ??
        localUnitDocumentsRepository({
          // Example: seed nothing by default (empty state).
          // You can inject real local docs from your store later.
        });
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return FutureBuilder<List<UnitDocument>>(
      future: _repo.listForUnit(unitId: widget.unitId),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return _LoadingState(theme: t);
        }
        if (snap.hasError) {
          return _ErrorState(
            message: 'Couldn’t load documents.',
            onRetry: () => setState(() {}),
          );
        }

        final docs = snap.data ?? const <UnitDocument>[];
        if (docs.isEmpty) {
          return _EmptyState(
            onAddPressed: () => _showNotReady(context),
          );
        }

        // Group docs
        final leases = docs.where((d) => d.type == 'Lease').toList();
        final receipts = docs.where((d) => d.type == 'Receipt').toList();
        final other = docs.where((d) => d.type != 'Lease' && d.type != 'Receipt').toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _HeaderRow(
              title: 'Documents',
              subtitle: 'Leases, receipts, and files for this unit.',
              onAdd: () => _showNotReady(context),
            ),
            const SizedBox(height: 12),

            _Section(
              title: 'Lease',
              icon: Icons.article_outlined,
              items: leases,
              emptyText: 'No lease uploaded yet.',
              onTapItem: (d) => _openDocPlaceholder(context, d),
            ),
            const SizedBox(height: 10),

            _Section(
              title: 'Receipts',
              icon: Icons.receipt_long_outlined,
              items: receipts,
              emptyText: 'No receipts yet.',
              onTapItem: (d) => _openDocPlaceholder(context, d),
            ),
            const SizedBox(height: 10),

            _Section(
              title: 'Other',
              icon: Icons.folder_outlined,
              items: other,
              emptyText: 'No other documents yet.',
              onTapItem: (d) => _openDocPlaceholder(context, d),
            ),

            const SizedBox(height: 14),
            _SafetyNote(),
          ],
        );
      },
    );
  }

  void _showNotReady(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document upload is coming soon (frontend-first local).'),
      ),
    );
  }

  void _openDocPlaceholder(BuildContext context, UnitDocument d) {
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
              Text(d.title, style: t.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text('${d.type} • ${_formatDate(d.createdAt)}', style: t.textTheme.bodyMedium),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Viewer will be added when storage is connected.')),
                  );
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open document'),
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

class _HeaderRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onAdd;

  const _HeaderRow({
    required this.title,
    required this.subtitle,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: t.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(subtitle, style: t.textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.upload_file),
          label: const Text('Add'),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<UnitDocument> items;
  final String emptyText;
  final ValueChanged<UnitDocument> onTapItem;

  const _Section({
    required this.title,
    required this.icon,
    required this.items,
    required this.emptyText,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(title, style: t.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 10),
            if (items.isEmpty)
              Text(emptyText, style: t.textTheme.bodyMedium)
            else
              ...items.map(
                (d) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.insert_drive_file_outlined),
                  title: Text(d.title),
                  subtitle: Text(_formatDate(d.createdAt)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => onTapItem(d),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddPressed;

  const _EmptyState({required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_open_outlined, size: 44),
            const SizedBox(height: 10),
            Text('No documents yet', style: t.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              'Upload a lease or receipt to keep everything organized for this unit.',
              textAlign: TextAlign.center,
              style: t.textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onAddPressed,
              icon: const Icon(Icons.upload_file),
              label: const Text('Add document'),
            ),
            const SizedBox(height: 10),
            Text(
              'local storage: upload/view will be enabled when storage is connected.',
              textAlign: TextAlign.center,
              style: t.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  final ThemeData theme;
  const _LoadingState({required this.theme});

  @override
  Widget build(BuildContext context) {
    // Lightweight skeletons without extra packages (review-safe).
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _skeletonLine(height: 22, widthFactor: 0.55),
        const SizedBox(height: 10),
        _skeletonLine(height: 14, widthFactor: 0.85),
        const SizedBox(height: 16),
        _skeletonCard(),
        const SizedBox(height: 10),
        _skeletonCard(),
        const SizedBox(height: 10),
        _skeletonCard(),
      ],
    );
  }

  Widget _skeletonCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _skeletonLine(height: 16, widthFactor: 0.35),
            const SizedBox(height: 10),
            _skeletonLine(height: 14, widthFactor: 0.9),
            const SizedBox(height: 8),
            _skeletonLine(height: 14, widthFactor: 0.8),
          ],
        ),
      ),
    );
  }

  Widget _skeletonLine({required double height, required double widthFactor}) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 10),
            Text(message, style: t.textTheme.titleMedium),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_outline),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Keep sensitive documents private. AYRNOW local stores files locally until cloud storage is enabled.',
                style: t.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
