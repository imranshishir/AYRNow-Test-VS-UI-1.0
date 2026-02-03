import 'dart:convert';
import 'package:flutter/material.dart';
import 'tenant_portable_models.dart';

class TenantPortableProfileScreen extends StatelessWidget {
  const TenantPortableProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = TenantPortableProfile.mock();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portable Tenant Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(profile: profile),
          const SizedBox(height: 14),

          Text(
            'What transfers',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const _CheckRow(text: 'Basic identity (name, contact)'),
          const _CheckRow(text: 'Rental history summary'),
          const _CheckRow(text: 'Review & rating summary'),
          const _CheckRow(text: 'Preferences (future)'),
          const SizedBox(height: 14),

          FilledButton.icon(
            onPressed: () => _showJsonPreview(context, profile),
            icon: const Icon(Icons.ios_share),
            label: const Text('Export (preview JSON)'),
          ),
          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.download),
            label: const Text('Import (coming soon)'),
          ),

          const SizedBox(height: 16),
          Text(
            'Note: This is UI-only mock data. Later, export will generate a signed share-link or file for the next landlord to review.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showJsonPreview(BuildContext context, TenantPortableProfile profile) {
    final pretty = const JsonEncoder.withIndent('  ').convert(profile.toJson());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.code),
                  const SizedBox(width: 8),
                  Text(
                    'Export preview (JSON)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    pretty,
                    style: const TextStyle(fontFamily: 'Menlo', fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export preview shown (mock).')),
                  );
                },
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final TenantPortableProfile profile;
  const _HeaderCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(profile.fullName, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(profile.currentAddress, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _MiniStat(label: 'Rating', value: profile.review.rating.toStringAsFixed(1))),
                const SizedBox(width: 10),
                Expanded(child: _MiniStat(label: 'Reviews', value: '${profile.review.reviewCount}')),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniStat(
                    label: 'On-time',
                    value: '${(profile.history.first.onTimePaymentRate * 100).round()}%',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String text;
  const _CheckRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
