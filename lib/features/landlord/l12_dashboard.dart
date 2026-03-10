import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LandlordDashboardScreen extends ConsumerWidget {
  const LandlordDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('L-12 • Landlord Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Get set up'),
          const SizedBox(height: 8),
          _primaryActionCard(
            context,
            title: 'Add apartment / unit',
            subtitle: 'Choose a property and add the first unit.',
            icon: Icons.apartment_outlined,
            routeName: '/L-25',
          ),
          const SizedBox(height: 12),
          _secondaryActionsRow(
            context,
            [
              _DashboardAction(
                label: 'Add Property',
                icon: Icons.add_home_outlined,
                routeName: '/L-20',
              ),
              _DashboardAction(
                label: 'Prepare lease',
                icon: Icons.description_outlined,
                routeName: '/L-25',
              ),
              _DashboardAction(
                label: 'Invite or manage residents',
                icon: Icons.people_alt_outlined,
                routeName: '/L-25',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _sectionTitle('Property management'),
          const SizedBox(height: 8),
          _listAction(
            context,
            title: 'My Properties',
            subtitle: 'View and manage your buildings.',
            icon: Icons.home_work_outlined,
            routeName: '/L-25',
          ),
          _listAction(
            context,
            title: 'Apartments & Units',
            subtitle: 'Drill into units from the property list.',
            icon: Icons.meeting_room_outlined,
            routeName: '/L-25',
          ),
          const SizedBox(height: 24),
          _sectionTitle('Money & operations'),
          const SizedBox(height: 8),
          _listAction(
            context,
            title: 'Rent board',
            subtitle: 'Track who is paid, due, or late.',
            icon: Icons.payments_outlined,
            routeName: '/L-23',
          ),
          _listAction(
            context,
            title: 'Maintenance',
            subtitle: 'Review and resolve open tickets.',
            icon: Icons.build_outlined,
            routeName: '/L-30',
          ),
          _listAction(
            context,
            title: 'Transfer requests',
            subtitle: 'Review incoming tenant profile transfers.',
            icon: Icons.swap_horiz_outlined,
            routeName: '/L-45',
          ),
          const SizedBox(height: 24),
          _sectionTitle('Secondary tools'),
          const SizedBox(height: 8),
          _listAction(
            context,
            title: 'Settings',
            subtitle: 'Configure notifications, access, and more.',
            icon: Icons.settings_outlined,
            routeName: '/L-38',
          ),
          _listAction(
            context,
            title: 'Notifications',
            subtitle: 'See alerts across your properties.',
            icon: Icons.notifications_outlined,
            routeName: '/I-10',
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _primaryActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String routeName,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, routeName),
      ),
    );
  }

  Widget _secondaryActionsRow(BuildContext context, List<_DashboardAction> actions) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actions
          .map(
            (a) => SizedBox(
              width: 220,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, a.routeName),
                icon: Icon(a.icon),
                label: Text(a.label),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _listAction(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String routeName,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, routeName),
      ),
    );
  }
}

class _DashboardAction {
  const _DashboardAction({
    required this.label,
    required this.icon,
    required this.routeName,
  });

  final String label;
  final IconData icon;
  final String routeName;
}

