import 'package:flutter/material.dart';
import 'package:ayrnow/features/tenant/screens/t_models.dart';
import 'package:ayrnow/features/tenant/screens/t_rent_flow.dart';
import 'package:ayrnow/features/tenant/screens/t_pay.dart';
import 'package:ayrnow/features/tenant/screens/t_tickets.dart';
import 'package:ayrnow/features/community/screens/community_tab_screen.dart';
import 'package:ayrnow/features/community/screens/community_sos_alert_screen.dart';
import 'package:ayrnow/features/invite/screens/invite_by_code_screen.dart';

void navigateToPay(BuildContext context, TenantProperty? property, TenantUnit? unit) {
  if (property != null && unit != null) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TenantPayRentScreen(property: property, unit: unit),
      ),
    );
  } else {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TenantPayHomeScreen()),
    );
  }
}

void navigateToTickets(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const TenantTicketsScreen()),
  );
}

void navigateToCommunity(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const CommunityTabScreen(isLandlord: false)),
  );
}

void navigateToSos(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const CommunitySosAlertScreen(isLandlord: false)),
  );
}

void navigateToInviteByCode(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const InviteByCodeScreen()),
  );
}

class DashboardSummaryCards extends StatelessWidget {
  final TenantProperty? nextProperty;
  final TenantUnit? nextUnit;
  final int maintenanceCount;
  final int communityUpdatesCount;

  const DashboardSummaryCards({
    super.key,
    this.nextProperty,
    this.nextUnit,
    this.maintenanceCount = 0,
    this.communityUpdatesCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Summary', style: t.textTheme.titleMedium),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.4,
          children: [
            _SummaryCard(
              icon: Icons.payments_outlined,
              title: 'Rent Status',
              subtitle: nextUnit != null
                  ? (nextUnit!.isOverdue ? 'Overdue' : nextUnit!.dueDateLabel)
                  : 'No upcoming',
              onTap: () => navigateToPay(context, nextProperty, nextUnit),
            ),
            _SummaryCard(
              icon: Icons.build_outlined,
              title: 'Maintenance',
              subtitle: maintenanceCount > 0 ? '$maintenanceCount request(s)' : 'No requests',
              onTap: () => navigateToTickets(context),
            ),
            _SummaryCard(
              icon: Icons.forum_outlined,
              title: 'Community',
              subtitle: communityUpdatesCount > 0 ? '$communityUpdatesCount new' : 'Updates',
              onTap: () => navigateToCommunity(context),
            ),
            _SummaryCard(
              icon: Icons.sos_outlined,
              title: 'SOS Alert',
              subtitle: 'Emergency',
              onTap: () => navigateToSos(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: t.colorScheme.primary),
              const SizedBox(height: 8),
              Text(title, style: t.textTheme.titleSmall),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: t.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
