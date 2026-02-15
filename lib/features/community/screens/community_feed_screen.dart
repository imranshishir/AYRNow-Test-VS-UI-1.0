import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../store/community_store.dart';
import '../widgets/community_create_post_sheet.dart';
import '../widgets/community_post_card.dart';
import '../widgets/community_scope_filter_row.dart';
import 'community_post_detail_screen.dart';
import 'package:ayrnow/ui/shared/widgets/empty_state_widget.dart';

class CommunityFeedScreen extends ConsumerWidget {
  final bool isLandlord;

  const CommunityFeedScreen({super.key, required this.isLandlord});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(communityStoreProvider);
    final store = ref.read(communityStoreProvider.notifier);

    final posts = store.visiblePosts;

    return Scaffold(
      body: Column(
        children: [
          CommunityScopeFilterRow(
            selected: state.selectedScope,
            onChanged: store.setScope,
          ),
          Expanded(
            child: posts.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.forum_outlined,
                    title: 'No posts yet',
                    subtitle: 'Be the first to share an update or create a post.',
                    actionLabel: 'Create post',
                    onAction: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        builder: (_) => CommunityCreatePostSheet(
                          isLandlord: isLandlord,
                          defaultScope: state.selectedScope,
                          onSubmit: (post) => store.addPost(post),
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, i) {
                      final p = posts[i];
                      final canPin = isLandlord &&
                          (p.type.name == 'announcement' || p.type.name == 'alert');

                      return CommunityPostCard(
                        post: p,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => CommunityPostDetailScreen(
                              postId: p.id,
                              isLandlord: isLandlord,
                            ),
                          ));
                        },
                        onLike: () => store.toggleLike(p.id),
                        onPinToggle: canPin ? () => store.togglePin(p.id, canPin: true) : null,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'community_feed_fab',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (_) => CommunityCreatePostSheet(
              isLandlord: isLandlord,
              defaultScope: state.selectedScope,
              onSubmit: (post) => store.addPost(post),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
    );
  }
}
