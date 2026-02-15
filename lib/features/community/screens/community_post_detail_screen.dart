import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../store/community_store.dart';
import '../data/community_mock_data.dart';
import '../models/community_models.dart';

class CommunityPostDetailScreen extends ConsumerStatefulWidget {
  final String postId;
  final bool isLandlord;

  const CommunityPostDetailScreen({
    super.key,
    required this.postId,
    required this.isLandlord,
  });

  @override
  ConsumerState<CommunityPostDetailScreen> createState() => _CommunityPostDetailScreenState();
}

class _CommunityPostDetailScreenState extends ConsumerState<CommunityPostDetailScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.read(communityStoreProvider.notifier);
    final post = store.findById(widget.postId);

    if (post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post')),
        body: const Center(child: Text('Post not found')),
      );
    }

    final canPin = widget.isLandlord &&
        (post.type.name == 'announcement' || post.type.name == 'alert');
    final comments = store.commentsFor(post.id);
    final currentAuthor = widget.isLandlord ? CommunityMockData.landlord : CommunityMockData.tenantB;

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
              const Icon(Icons.mode_comment_outlined),
              const SizedBox(width: 6),
              Text('${post.commentCount}', style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          Text('Comments', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (comments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No comments yet. Be the first to comment.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            )
          else
            ...comments.map((c) => _CommentTile(comment: c)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Write a comment...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: 2,
                  onSubmitted: (_) => _submitComment(store, post.id, currentAuthor),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () => _submitComment(store, post.id, currentAuthor),
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitComment(CommunityStore store, String postId, CommunityAuthor author) {
    final body = _commentController.text.trim();
    if (body.isEmpty) return;
    store.addComment(postId, body, author);
    _commentController.clear();
    setState(() {});
  }
}

class _CommentTile extends StatelessWidget {
  final CommunityComment comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            child: Text(comment.author.name.substring(0, 1).toUpperCase()),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.author.name,
                  style: t.textTheme.labelLarge,
                ),
                const SizedBox(height: 2),
                Text(comment.body, style: t.textTheme.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  _formatDate(comment.createdAt),
                  style: t.textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
