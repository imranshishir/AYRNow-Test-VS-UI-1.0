import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/state/providers.dart';
import '../models/tenant_transfer_models.dart';

class TenantProfileExportScreen extends ConsumerWidget {
  const TenantProfileExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(tenantProfileProvider);
    final requestAsync = ref.watch(myTransferRequestProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('T-45 • Portable Tenant Profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => _ErrorState(message: err.toString(), onRetry: () => ref.invalidate(tenantProfileProvider)),
        data: (profile) {
          return requestAsync.when(
            loading: () => _buildContent(context, ref, profile, null),
            error: (err, st) => _buildContent(context, ref, profile, null),
            data: (req) => _buildContent(context, ref, profile, req),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    TenantProfile profile,
    TransferRequest? activeRequest,
  ) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Portable Tenant Profile',
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(
          'Your verified rental history, payment score, and reviews. Share this profile when applying to a new landlord.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),

        if (activeRequest != null) _StatusBanner(request: activeRequest),
        if (activeRequest != null) const SizedBox(height: 16),

        _ProfileSummaryCard(profile: profile),
        const SizedBox(height: 16),

        _Section(title: 'Occupancy History', child: _OccupancyList(history: profile.occupancyHistory)),
        const SizedBox(height: 16),

        _Section(title: 'Reviews', child: _ReviewsList(reviews: profile.reviews)),
        const SizedBox(height: 16),

        _Section(title: 'Documents', child: _DocumentsList(documents: profile.documents)),
        const SizedBox(height: 24),

        if (activeRequest == null || !activeRequest.isActive) ...[
          FilledButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/T-45/request')
                .then((_) => ref.invalidate(myTransferRequestProvider)),
            icon: const Icon(Icons.send_outlined),
            label: const Text('Request Transfer'),
          ),
          const SizedBox(height: 10),
        ],
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDF export will be available after backend. This is a preview.'),
              ),
            );
          },
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('Export (Preview)'),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final TransferRequest request;

  const _StatusBanner({required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = request.status;
    final color = status == TransferRequestStatus.pending
        ? Colors.orange
        : status == TransferRequestStatus.accepted
            ? Colors.green
            : Colors.red;
    return Card(
      color: color.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hourglass_top, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Transfer Request: ${status.label}',
                  style: theme.textTheme.titleSmall?.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Sent to ${request.targetEmailOrCode}',
              style: theme.textTheme.bodySmall,
            ),
            if (request.decidedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Decided ${DateFormat.yMMMd().format(request.decidedAt!)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (request.landlordMessage != null && request.landlordMessage!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Landlord: ${request.landlordMessage}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  final TenantProfile profile;

  const _ProfileSummaryCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(profile.fullName, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Row(
              children: [
                _Pill(label: 'Payment Score: ${profile.paymentScore}/100'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              profile.currentAddress,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _OccupancyList extends StatelessWidget {
  final List<OccupancyRecord> history;

  const _OccupancyList({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return _EmptyPlaceholder(message: 'No occupancy history yet.');
    }
    return Column(
      children: history
          .map(
            (o) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text('${o.propertyName} • ${o.unitLabel}'),
                subtitle: Text(
                  '${DateFormat.yMMM().format(o.startDate)} – ${o.endDate != null ? DateFormat.yMMM().format(o.endDate!) : 'Present'}${o.landlordName != null ? '\n${o.landlordName}' : ''}',
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ReviewsList extends StatelessWidget {
  final List<TenantReview> reviews;

  const _ReviewsList({required this.reviews});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return _EmptyPlaceholder(message: 'No reviews yet.');
    }
    return Column(
      children: reviews
          .map(
            (r) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(r.reviewerName, style: Theme.of(context).textTheme.titleSmall),
                        const Spacer(),
                        Text('${'★' * r.rating}${'☆' * (5 - r.rating)}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(r.comment, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DocumentsList extends StatelessWidget {
  final List<ProfileDocument> documents;

  const _DocumentsList({required this.documents});

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return _EmptyPlaceholder(message: 'No documents listed.');
    }
    return Column(
      children: documents
          .map(
            (d) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  d.status == 'verified' ? Icons.verified : d.status == 'uploaded' ? Icons.upload_file : Icons.looks_one_outlined,
                  color: d.status == 'missing' ? Colors.grey : null,
                ),
                title: Text('${d.type}: ${d.filename}'),
                trailing: Chip(
                  label: Text(d.status, style: const TextStyle(fontSize: 11)),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  final String message;

  const _EmptyPlaceholder({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
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
