import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/community_models.dart';
import '../store/community_store.dart';
import '../widgets/community_create_post_sheet.dart';
import '../widgets/community_post_card.dart';
import 'community_post_detail_screen.dart';

class CommunityGroupFeedScreen extends ConsumerWidget {
  final bool isLandlord;
  final CommunityScope scope;

  const CommunityGroupFeedScreen({
    super.key,
    required this.isLandlord,
    required this.scope,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(communityStoreProvider);
    final store = ref.read(communityStoreProvider.notifier);

    final posts = state.posts
        .where((p) => p.scope.id == scope.id && p.scope.type == scope.type)
        .toList()
      ..sort((a, b) {
        final pin = (b.isPinned ? 1 : 0) - (a.isPinned ? 1 : 0);
        if (pin != 0) return pin;
        return b.createdAt.compareTo(a.createdAt);
      });

    return Scaffold(
      appBar: AppBar(title: Text(scope.label)),
      body: ListView.builder(
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'community_group_feed_fab',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (_) => CommunityCreatePostSheet(
              isLandlord: isLandlord,
              defaultScope: scope,
              onSubmit: (post) => store.addPost(post),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Post'),
      ),
    );
  }
}
