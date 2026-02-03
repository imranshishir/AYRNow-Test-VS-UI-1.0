import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/community_mock_data.dart';
import '../models/community_models.dart';
import '../store/community_store.dart';
import '../widgets/community_post_card.dart';
import 'community_post_detail_screen.dart';
import 'community_sos_alert_screen.dart';

class CommunityInboxScreen extends ConsumerStatefulWidget {
  final bool isLandlord;
  const CommunityInboxScreen({super.key, required this.isLandlord});

  @override
  ConsumerState<CommunityInboxScreen> createState() => _CommunityInboxScreenState();
}

class _CommunityInboxScreenState extends ConsumerState<CommunityInboxScreen> {
  static const _tick = Duration(seconds: 30);
  Timer? _timer;

  // Forces rebuild so time-based "auto-expire" updates visually.
  int _pulse = 0;

  // UI-only dismissal (per session).
  final Set<String> _dismissedCriticalIds = <String>{};

  // UI-only acknowledgements (per session): postId -> set of userIds.
  final Map<String, Set<String>> _ackByPostId = <String, Set<String>>{};

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_tick, (_) {
      if (!mounted) return;
      setState(() => _pulse++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // reference _pulse so analyzer doesn't complain about unused state
    final _ = _pulse;

    final store = ref.read(communityStoreProvider.notifier);
    final posts = store.visiblePosts;

    final now = DateTime.now();

    // CRITICAL: Alerts that are fresh (auto-expire after 10 minutes).
    final critical = posts.where((p) {
      final isCriticalType = p.type == CommunityPostType.alert;
      if (!isCriticalType) return false;
      if (_dismissedCriticalIds.contains(p.id)) return false;
      final age = now.difference(p.createdAt);
      return age.inMinutes <= 10;
    }).toList();

    // ANNOUNCEMENTS: pinned or announcement type, excluding critical duplicates.
    final announcements = posts.where((p) {
      final isAnn = p.type == CommunityPostType.announcement || p.isPinned;
      final inCritical = critical.any((c) => c.id == p.id);
      return isAnn && !inCritical;
    }).toList();

    // ACTIVITY: everything else.
    final activity = posts.where((p) {
      final isCriticalType = p.type == CommunityPostType.alert;
      final isAnn = p.type == CommunityPostType.announcement || p.isPinned;
      return !isCriticalType && !isAnn;
    }).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        _SectionHeader(
          title: 'Critical',
          subtitle: critical.isEmpty ? 'No active alerts' : 'Auto-expires after 10 minutes',
          icon: Icons.warning_amber_rounded,
        ),
        if (critical.isEmpty)
          const _EmptyTile(
            title: 'All clear',
            subtitle: 'No emergency alerts right now.',
          )
        else
          ...critical.map((p) {
            final ackSet = _ackByPostId[p.id] ?? <String>{};
            final ackCount = ackSet.length;

            // Choose "current user" mock identity for demo:
            // - landlord uses landlord.id
            // - tenant uses tenantA.id (simple, consistent)
            final currentUserId = widget.isLandlord
                ? CommunityMockData.landlord.id
                : CommunityMockData.tenantA.id;

            final iAcknowledged = ackSet.contains(currentUserId);

            return Column(
              children: [
                _CriticalWrap(
                  child: CommunityPostCard(
                    post: p,
                    onTap: () => _openPost(context, p.id),
                    onLike: () => store.toggleLike(p.id),
                    onPinToggle: widget.isLandlord &&
                            (p.type == CommunityPostType.alert || p.type == CommunityPostType.announcement)
                        ? () => store.togglePin(p.id, canPin: true)
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                  child: Row(
                    children: [
                      // Ack badge / text
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Text(
                          widget.isLandlord
                              ? '$ackCount acknowledged'
                              : (iAcknowledged ? 'You acknowledged' : '$ackCount acknowledged'),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      const Spacer(),

                      // Tenant: I’m OK button
                      if (!widget.isLandlord)
                        FilledButton.icon(
                          onPressed: iAcknowledged
                              ? null
                              : () {
                                  setState(() {
                                    final set = (_ackByPostId[p.id] ?? <String>{}).toSet();
                                    set.add(currentUserId);
                                    _ackByPostId[p.id] = set;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Acknowledged (mock).')),
                                  );
                                },
                          icon: Icon(iAcknowledged ? Icons.check_circle : Icons.health_and_safety_outlined, size: 18),
                          label: Text(iAcknowledged ? 'Acknowledged' : 'I’m OK'),
                        ),

                      // Landlord: View acknowledgements
                      if (widget.isLandlord)
                        TextButton.icon(
                          onPressed: () => _showAckList(context, p.id),
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          label: const Text('View'),
                        ),

                      // Everyone: Dismiss
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _dismissedCriticalIds.add(p.id));
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Dismiss'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),

        const SizedBox(height: 8),

        _SectionHeader(
          title: 'Announcements',
          subtitle: announcements.isEmpty ? 'No announcements' : 'From your landlord & building staff',
          icon: Icons.campaign_outlined,
        ),
        if (announcements.isEmpty)
          const _EmptyTile(
            title: 'Nothing posted yet',
            subtitle: 'Announcements will show up here.',
          )
        else
          ...announcements.map((p) => CommunityPostCard(
                post: p,
                onTap: () => _openPost(context, p.id),
                onLike: () => store.toggleLike(p.id),
                onPinToggle: widget.isLandlord &&
                        (p.type == CommunityPostType.alert || p.type == CommunityPostType.announcement)
                    ? () => store.togglePin(p.id, canPin: true)
                    : null,
              )),

        const SizedBox(height: 8),

        _SectionHeader(
          title: 'Activity',
          subtitle: activity.isEmpty ? 'No recent activity' : 'Updates from your community',
          icon: Icons.notifications_none,
        ),
        if (activity.isEmpty)
          const _EmptyTile(
            title: 'You’re caught up',
            subtitle: 'New likes and replies will show up here.',
          )
        else
          ...activity.map((p) => CommunityPostCard(
                post: p,
                onTap: () => _openPost(context, p.id),
                onLike: () => store.toggleLike(p.id),
                onPinToggle: null,
              )),

        const SizedBox(height: 14),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => CommunitySosAlertScreen(isLandlord: widget.isLandlord),
              ));
            },
            icon: const Icon(Icons.sos_rounded),
            label: const Text('Open SOS / Fire Alert'),
          ),
        ),
      ],
    );
  }

  void _openPost(BuildContext context, String postId) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CommunityPostDetailScreen(postId: postId, isLandlord: widget.isLandlord),
    ));
  }

  void _showAckList(BuildContext context, String postId) {
    final set = _ackByPostId[postId] ?? <String>{};

    // Demo people list (expand later when backend exists)
    final people = <dynamic>[
      CommunityMockData.tenantA,
      CommunityMockData.tenantB,
      CommunityMockData.landlord,
    ];

    final acknowledged = people.where((u) => set.contains(u.id)).toList();
    final notAck = people.where((u) => u.id != CommunityMockData.landlord.id && !set.contains(u.id)).toList();

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Acknowledgements', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(
                'Mock view — later this will come from backend per building/unit.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),

              Text('Acknowledged', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              if (acknowledged.isEmpty)
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('No acknowledgements yet'),
                )
              else
                ...acknowledged.map((u) => ListTile(
                      leading: const Icon(Icons.check_circle_outline),
                      title: Text(u.name),
                      subtitle: Text(u.roleLabel),
                    )),

              const SizedBox(height: 10),
              Text('Not acknowledged', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              if (notAck.isEmpty)
                const ListTile(
                  leading: Icon(Icons.check_circle),
                  title: Text('Everyone acknowledged'),
                )
              else
                ...notAck.map((u) => ListTile(
                      leading: const Icon(Icons.schedule),
                      title: Text(u.name),
                      subtitle: Text(u.roleLabel),
                    )),
            ],
          ),
        );
      },
    );
  }
}

class _CriticalWrap extends StatelessWidget {
  final Widget child;
  const _CriticalWrap({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cs.errorContainer.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.error.withValues(alpha: 0.35)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              left: 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: cs.error.withValues(alpha: 0.90),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.priority_high_rounded, size: 18),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: cs.error.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          'EMERGENCY',
                          style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
