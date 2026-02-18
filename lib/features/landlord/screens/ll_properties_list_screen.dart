import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'll_property_detail_screen.dart';
import 'll_add_property_screen.dart';
import 'package:ayrnow/ui/shared/switch_role_menu.dart';
import 'package:ayrnow/core/api/providers/properties_provider.dart';
import 'package:ayrnow/core/api/providers/feature_flags_provider.dart';
import 'package:ayrnow/ui/shared/widgets/loading_indicator.dart';
import 'package:ayrnow/ui/shared/widgets/empty_state_widget.dart';

class LlPropertiesListScreen extends ConsumerWidget {
  const LlPropertiesListScreen({super.key});

  static List<_Property> _mockProperties = const [
    _Property(id: 'P-1001', name: 'Harlem Heights', type: 'Residential', city: 'Buffalo, NY', units: 12),
    _Property(id: 'P-2001', name: 'Elmwood Plaza', type: 'Commercial', city: 'Buffalo, NY', units: 24),
    _Property(id: 'P-3001', name: 'Lakeview Villas', type: 'Residential', city: 'Rochester, NY', units: 18),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useRealApi = ref.watch(featureFlagsProvider).properties;
    final asyncProperties = ref.watch(propertiesListProvider);

    final properties = useRealApi
        ? asyncProperties.when(
            data: (list) => list
                .map((p) {
                  final city = [p.city, p.state].whereType<String>().where((s) => s.isNotEmpty).join(', ');
                  return _Property(
                    id: p.id,
                    name: p.name,
                    type: 'Residential',
                    city: city.isEmpty ? '—' : city,
                    units: 0,
                  );
                })
                .toList(),
            loading: () => null,
            error: (_, __) => null,
          )
        : null;

    final displayList = properties ?? _mockProperties;
    final isLoading = useRealApi && asyncProperties.isLoading;
    final hasError = useRealApi && asyncProperties.hasError;

    final isEmpty = displayList.isEmpty && !isLoading && !hasError;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        actions: const [SwitchRoleMenu()],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'll_properties_list_add_property_fab',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LlAddPropertyScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add property'),
      ),
      body: isLoading
          ? const Center(child: LoadingIndicator())
          : hasError
              ? EmptyStateWidget(
                  title: 'Could not load properties',
                  subtitle: 'Check your connection and try again.',
                  icon: Icons.cloud_off_outlined,
                  onRetry: () => ref.invalidate(propertiesListProvider),
                )
              : isEmpty
                  ? EmptyStateWidget(
                      title: 'No properties yet',
                      subtitle: 'Add your first property to get started.',
                      icon: Icons.apartment_outlined,
                      onRetry: () => ref.invalidate(propertiesListProvider),
                    )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: displayList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final p = displayList[i];
                    return _PropertyCard(
                      p: p,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => LlPropertyDetailScreen(property: p)),
                      ),
                    );
                  },
                ),
    );
  }
}

class _Property {
  final String id;
  final String name;
  final String type;
  final String city;
  final int units;
  const _Property(
      {required this.id,
      required this.name,
      required this.type,
      required this.city,
      required this.units});
}

class _PropertyCard extends StatelessWidget {
  final _Property p;
  final VoidCallback onTap;
  const _PropertyCard({required this.p, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: cs.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: cs.primaryContainer,
              ),
              child: Icon(
                  p.type == 'Commercial' ? Icons.storefront : Icons.apartment,
                  color: cs.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('${p.type} • ${p.city}',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ]),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${p.units} units',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                const Icon(Icons.chevron_right),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
