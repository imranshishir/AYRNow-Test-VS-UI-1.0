import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/providers.dart';
import '../models/community_models.dart';
import 'community_post_detail_screen.dart';
import 'community_create_post_screen.dart';

/// Community feed: posts with filters [All] [Property] [Unit].
/// Landlord: FAB "New Announcement". Tenant: read + comment only.
class CommunityHomeScreen extends ConsumerWidget {
  final bool isLandlord;

  const CommunityHomeScreen({super.key, required this.isLandlord});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final scopeFilter = ref.watch(_communityScopeFilterProvider);
    final postsAsync = ref.watch(communityPostsProvider((role: user.role.name, scopeFilter: scopeFilter)));

    return Scaffold(
      body: Column(
        children: [
          _FilterRow(
            selected: scopeFilter,
            onChanged: (v) => ref.read(_communityScopeFilterProvider.notifier).state = v,
          ),
          Expanded(
            child: postsAsync.when(
              data: (posts) => posts.isEmpty
                  ? _EmptyState(
                      isLandlord: isLandlord,
                      onCreate: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CommunityCreatePostScreen(
                            isLandlord: isLandlord,
                            authorName: user.name,
                            authorRole: user.role.name,
                            onCreated: () => ref.invalidate(communityPostsProvider((role: user.role.name, scopeFilter: scopeFilter))),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (_, i) => _PostCard(
                        post: posts[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CommunityPostDetailScreen(
                              post: posts[i],
                              isLandlord: isLandlord,
                            ),
                          ),
                        ),
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: isLandlord
          ? FloatingActionButton.extended(
              heroTag: 'community_fab',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CommunityCreatePostScreen(
                    isLandlord: true,
                    authorName: user.name,
                    authorRole: user.role.name,
                    onCreated: () => ref.invalidate(communityPostsProvider((role: user.role.name, scopeFilter: scopeFilter))),
                  ),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('New Announcement'),
            )
          : null,
    );
  }
}

final _communityScopeFilterProvider = StateProvider<String?>((ref) => null);

class _FilterRow extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _FilterRow({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selected == null,
              onSelected: (_) => onChanged(null),
            ),
          ),
          FilterChip(
            label: const Text('Property'),
            selected: selected == 'property',
            onSelected: (_) => onChanged('property'),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Unit'),
            selected: selected == 'unit',
            onSelected: (_) => onChanged('unit'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isLandlord;
  final VoidCallback onCreate;

  const _EmptyState({required this.isLandlord, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.forum_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No posts yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share an update or create a post.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (isLandlord) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Create announcement'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onTap;

  const _PostCard({required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUrgent = post.priority == CommunityPostPriority.urgent;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Urgent', style: theme.textTheme.labelSmall),
                    ),
                  if (isUrgent) const SizedBox(width: 8),
                  Text(
                    '${post.authorName} • ${post.authorRole}',
                    style: theme.textTheme.labelMedium,
                  ),
                  const Spacer(),
                  Text(_timeAgo(post.createdAt), style: theme.textTheme.labelSmall),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                post.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.mode_comment_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('${post.commentCount}', style: theme.textTheme.labelSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
