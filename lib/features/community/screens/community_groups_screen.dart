import 'package:flutter/material.dart';
import '../data/community_mock_data.dart';
import '../models/community_models.dart';
import 'community_group_feed_screen.dart';

class CommunityGroupsScreen extends StatelessWidget {
  final bool isLandlord;

  const CommunityGroupsScreen({super.key, required this.isLandlord});

  @override
  Widget build(BuildContext context) {
    final groups = CommunityMockData.scopes;

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: groups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final g = groups[i];
        return Card(
          elevation: 0,
          child: ListTile(
            leading: Icon(_iconFor(g.type)),
            title: Text(g.label),
            subtitle: Text(_subtitleFor(g.type)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CommunityGroupFeedScreen(
                  isLandlord: isLandlord,
                  scope: g,
                ),
              ));
            },
          ),
        );
      },
    );
  }

  IconData _iconFor(CommunityScopeType t) {
    switch (t) {
      case CommunityScopeType.property:
        return Icons.apartment_outlined;
      case CommunityScopeType.building:
        return Icons.domain_outlined;
      case CommunityScopeType.unit:
        return Icons.home_outlined;
    }
  }

  String _subtitleFor(CommunityScopeType t) {
    switch (t) {
      case CommunityScopeType.property:
        return 'Everyone in the property';
      case CommunityScopeType.building:
        return 'People in this building';
      case CommunityScopeType.unit:
        return 'Unit-specific updates';
    }
  }
}
