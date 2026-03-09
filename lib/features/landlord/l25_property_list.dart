import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/providers.dart';

void _openAddProperty(BuildContext context, WidgetRef ref) {
  Navigator.pushNamed(context, '/L-20').then((result) {
    ref.invalidate(landlordPropertiesProvider);
    if (!context.mounted) return;
    final map = result is Map ? result as Map : null;
    final id = map?['propertyId']?.toString();
    if (id != null && id.isNotEmpty) {
      Navigator.pushNamed(
        context,
        '/L-22',
        arguments: {'propertyId': id, 'propertyLabel': map?['propertyLabel']?.toString() ?? id},
      );
    }
  });
}

class PropertyListScreen extends ConsumerWidget {
  const PropertyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertiesAsync = ref.watch(landlordPropertiesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Properties & Units')),
      body: propertiesAsync.when(
        loading: () => const Center(child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        )),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Could not load properties.', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(landlordPropertiesProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (properties) {
          if (properties.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.apartment_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    Text('No properties yet', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first property to get started.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _openAddProperty(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Property'),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final p = properties[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.apartment),
                  title: Text(p.name),
                  subtitle: Text(p.addressLine),
                  isThreeLine: p.addressLine.isNotEmpty,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/L-22',
                    arguments: {'propertyId': p.id, 'propertyLabel': p.name},
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddProperty(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Property'),
      ),
    );
  }
}
