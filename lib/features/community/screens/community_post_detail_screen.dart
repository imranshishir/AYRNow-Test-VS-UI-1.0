import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../store/community_store.dart';

class CommunityPostDetailScreen extends ConsumerWidget {
  final String postId;
  final bool isLandlord;

  const CommunityPostDetailScreen({
    super.key,
    required this.postId,
    required this.isLandlord,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.read(communityStoreProvider.notifier);
    final post = store.findById(postId);

    if (post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post')),
        body: const Center(child: Text('Post not found')),
      );
    }

    final canPin = isLandlord &&
        (post.type.name == 'announcement' || post.type.name == 'alert');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          if (canPin)
            IconButton(
              tooltip: post.isPinned ? 'Unpin' : 'Pin',
              onPressed: () => store.togglePin(post.id, canPin: true),
              icon: Icon(post.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Chip(label: Text(post.scope.label)),
              const SizedBox(width: 8),
              Chip(label: Text(post.author.name)),
            ],
          ),
          const SizedBox(height: 12),
          if (post.title != null) ...[
            Text(post.title!, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
          ],
          Text(post.body, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 18),
          Row(
            children: [
              FilledButton.tonalIcon(
                onPressed: () => store.toggleLike(post.id),
                icon: Icon(post.iLiked ? Icons.thumb_up : Icons.thumb_up_outlined),
                label: Text('${post.likeCount}'),
              ),
              const SizedBox(width: 10),
              FilledButton.tonalIcon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Comments UI comes next (v1.1).')),
                  );
                },
                icon: const Icon(Icons.mode_comment_outlined),
                label: Text('${post.commentCount}'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Details',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text('Backend-ready: postId=$postId'),
        ],
      ),
    );
  }
}
