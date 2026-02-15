import 'package:flutter/material.dart';
import 'package:ayrnow/features/landlord/screens/landlord_demo_store.dart';
import 'package:ayrnow/features/landlord/screens/ll_dashboard_data.dart';
import 'package:ayrnow/features/landlord/screens/ll_dashboard_sections.dart';

class LlDashboardScreen extends StatelessWidget {
  final LandlordDemoStore store;
  final ValueChanged<int>? goToTab;

  const LlDashboardScreen({super.key, required this.store, this.goToTab});

  @override
  Widget build(BuildContext context) {
    final data = LlDashboardData.fromStore(store);
    final t = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text('Landlord Dashboard', style: t.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text('Portfolio overview', style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 20),

        if (data.properties == 0 || data.units == 0) ...[
          LlDashboardInfoBanner(
            title: 'Add your first property',
            subtitle: 'Once you add properties and units, you\'ll see rent, maintenance, and activity here.',
            actionLabel: 'Add property',
            onAction: () => Navigator.pushNamed(context, '/landlord/add-property'),
          ),
          const SizedBox(height: 20),
        ],

        LlDashboardFinancialCard(data: data),
        const SizedBox(height: 20),

        Text('Portfolio', style: t.textTheme.titleMedium),
        const SizedBox(height: 10),
        LlDashboardPortfolioGrid(data: data, goToTab: goToTab, onFallback: (route) => Navigator.pushNamed(context, route)),
        const SizedBox(height: 20),

        if (data.hasUrgentAttention) ...[
          LlDashboardUrgentSection(data: data),
          const SizedBox(height: 20),
        ],

        Text('Quick actions', style: t.textTheme.titleMedium),
        const SizedBox(height: 10),
        LlDashboardQuickActions(goToTab: goToTab),
      ],
    );
  }
}
