import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ayrnow/features/landlord/screens/ll_dashboard_data.dart';
import 'package:ayrnow/ui/shared/widgets/section_card.dart';
import 'package:ayrnow/core/theme/app_colors.dart';
import 'package:ayrnow/features/account_management/screens/managed_users_screen.dart';

class LlDashboardFinancialCard extends StatelessWidget {
  final LlDashboardData data;

  const LlDashboardFinancialCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final money = NumberFormat.simpleCurrency(locale: 'en_US');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total collected', style: t.textTheme.labelMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text(money.format(data.totalCollectedThisMonth), style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(data.trendUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                              size: 14, color: data.trendUp ? t.colorScheme.primary : t.colorScheme.error),
                          const SizedBox(width: 4),
                          Text('This month', style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Outstanding', style: t.textTheme.labelMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text(money.format(data.outstanding), style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Collection rate', style: t.textTheme.labelMedium?.copyWith(color: t.colorScheme.onSurfaceVariant)),
                const Spacer(),
                Text('${data.collectionRatePercent.toStringAsFixed(1)}%', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LlDashboardPortfolioGrid extends StatelessWidget {
  final LlDashboardData data;
  final ValueChanged<int>? goToTab;
  final ValueChanged<String> onFallback;

  const LlDashboardPortfolioGrid({super.key, required this.data, required this.goToTab, required this.onFallback});

  void _go(BuildContext context, int tabIndex, String route) {
    if (goToTab != null) {
      goToTab!(tabIndex);
      return;
    }
    onFallback(route);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.15,
      children: [
        _GridCard(icon: Icons.apartment_rounded, iconBg: cs.primaryContainer, onIcon: cs.onPrimaryContainer, value: '${data.properties}', subtitle: 'Properties', onTap: () => _go(context, 1, '/landlord/properties')),
        _GridCard(icon: Icons.door_front_door_rounded, iconBg: cs.secondaryContainer, onIcon: cs.onSecondaryContainer, value: '${data.units}', subtitle: 'Units', onTap: () => _go(context, 1, '/landlord/properties')),
        _GridCard(icon: Icons.pie_chart_outline_rounded, iconBg: cs.surfaceContainerHighest, onIcon: cs.onSurfaceVariant, value: '${data.occupancyRatePercent.toStringAsFixed(0)}%', subtitle: 'Occupancy', onTap: () => _go(context, 1, '/landlord/properties')),
        _GridCard(icon: Icons.construction_rounded, iconBg: cs.errorContainer, onIcon: cs.onErrorContainer, value: '${data.openTickets}', subtitle: 'Open tickets', onTap: () => _go(context, 3, '/landlord/maintenance')),
      ],
    );
  }
}

class _GridCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color onIcon;
  final String value;
  final String subtitle;
  final VoidCallback onTap;

  const _GridCard({required this.icon, required this.iconBg, required this.onIcon, required this.value, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return SectionCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 22, color: onIcon),
          ),
          const SizedBox(height: 10),
          Text(value, style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(subtitle, style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class LlDashboardUrgentSection extends StatelessWidget {
  final LlDashboardData data;

  const LlDashboardUrgentSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkWarningContainer : AppColors.lightWarningContainer;
    final fg = isDark ? AppColors.darkOnWarningContainer : AppColors.lightOnWarningContainer;
    final items = <String>[];
    if (data.overduePayments > 0) items.add('${data.overduePayments} overdue payment${data.overduePayments > 1 ? 's' : ''}');
    if (data.urgentTickets > 0) items.add('${data.urgentTickets} urgent ticket${data.urgentTickets > 1 ? 's' : ''}');
    if (data.outstanding > 0 && data.overduePayments == 0) items.add('Outstanding balance due');
    if (items.isEmpty) return const SizedBox.shrink();
    return Card(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Requires attention', style: t.textTheme.titleMedium?.copyWith(color: fg, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ...items.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 18, color: fg),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e, style: t.textTheme.bodyMedium?.copyWith(color: fg))),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class LlDashboardQuickActions extends StatelessWidget {
  final ValueChanged<int>? goToTab;

  const LlDashboardQuickActions({super.key, required this.goToTab});

  void _go(BuildContext context, int tabIndex, String route) {
    if (goToTab != null) {
      goToTab!(tabIndex);
      return;
    }
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _ActionChip(label: 'Add Property', icon: Icons.add_home_rounded, onTap: () => Navigator.pushNamed(context, '/landlord/add-property')),
        _ActionChip(label: 'Add Unit', icon: Icons.add_rounded, onTap: () => _go(context, 1, '/landlord/properties')),
        _ActionChip(label: 'Add Staff', icon: Icons.person_add_rounded, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManagedUsersScreen(isLandlord: true)))),
        _ActionChip(label: 'View Reports', icon: Icons.assessment_rounded, onTap: () {}),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionChip({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        minimumSize: const Size(0, 40),
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}

class LlDashboardInfoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const LlDashboardInfoBanner({super.key, required this.title, required this.subtitle, required this.actionLabel, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: BorderRadius.circular(14)),
              child: Icon(Icons.info_outline, color: cs.onSecondaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: t.textTheme.titleSmall),
                  const SizedBox(height: 6),
                  Text(subtitle, style: t.textTheme.bodyMedium),
                  const SizedBox(height: 10),
                  FilledButton.tonal(onPressed: onAction, child: Text(actionLabel)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
