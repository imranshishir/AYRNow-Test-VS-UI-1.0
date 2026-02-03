import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../store/community_store.dart';
import '../data/community_mock_data.dart';
import '../models/community_models.dart';

import 'community_feed_screen.dart';
import 'community_groups_screen.dart';
import 'community_inbox_screen.dart';
import 'community_sos_alert_screen.dart';

class CommunityTabScreen extends ConsumerStatefulWidget {
  final bool isLandlord;

  const CommunityTabScreen({super.key, required this.isLandlord});

  @override
  ConsumerState<CommunityTabScreen> createState() => _CommunityTabScreenState();
}

class _CommunityTabScreenState extends ConsumerState<CommunityTabScreen> {
  bool _didInitScope = false;

  @override
  void initState() {
    super.initState();

    // Defer provider updates until after the first build.
    Future.microtask(() {
      if (!mounted || _didInitScope) return;

      final st = ref.read(communityStoreProvider);
      if (st.selectedScope != null) {
        _didInitScope = true;
        return;
      }

      final store = ref.read(communityStoreProvider.notifier);
      final scopes = CommunityMockData.scopes;

      CommunityScope? pick;
      if (widget.isLandlord) {
        pick = scopes.where((s) => s.type == CommunityScopeType.property).cast<CommunityScope?>().firstWhere(
              (e) => e != null,
              orElse: () => null,
            );
      } else {
        pick = scopes.where((s) => s.type == CommunityScopeType.building).cast<CommunityScope?>().firstWhere(
              (e) => e != null,
              orElse: () => null,
            );
      }

      store.setScope(pick ?? (scopes.isNotEmpty ? scopes.first : null));
      _didInitScope = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community'),
          actions: [
            IconButton(
              tooltip: 'SOS',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => CommunitySosAlertScreen(isLandlord: widget.isLandlord),
                ));
              },
              icon: const Icon(Icons.sos_rounded),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Feed', icon: Icon(Icons.view_stream_outlined)),
              Tab(text: 'Groups', icon: Icon(Icons.groups_outlined)),
              Tab(text: 'Inbox', icon: Icon(Icons.notifications_none)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CommunityFeedScreen(isLandlord: widget.isLandlord),
            CommunityGroupsScreen(isLandlord: widget.isLandlord),
            CommunityInboxScreen(isLandlord: widget.isLandlord),
          ],
        ),
      ),
    );
  }
}
