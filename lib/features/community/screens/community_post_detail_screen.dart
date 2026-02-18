import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/providers.dart';
import '../../notifications/models/notification_models.dart';
import '../models/community_models.dart';

class CommunityPostDetailScreen extends ConsumerStatefulWidget {
  final CommunityPost post;
  final bool isLandlord;

  const CommunityPostDetailScreen({
    super.key,
    required this.post,
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
    final commentsAsync = ref.watch(communityCommentsProvider(widget.post.id));
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: commentsAsync.when(
        data: (comments) => _buildBody(context, widget.post, comments, user.name),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, CommunityPost post, List<CommunityComment> comments, String currentUserName) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _PostContent(post: post),
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
                    onSubmitted: (_) => _submitComment(currentUserName),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _submitComment(currentUserName),
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        );
  }

  Future<void> _submitComment(String currentUserName) async {
    final body = _commentController.text.trim();
    if (body.isEmpty) return;

    await ref.read(reposProvider).communityRepo.addComment(widget.post.id, body);
    ref.read(notificationsControllerProvider).add(AppNotification(
      id: 'n-${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.comment,
      title: 'New comment',
      body: 'Comment added on: ${widget.post.title}',
      createdAt: DateTime.now(),
      route: '/community',
      targetRole: NotificationTargetRole.any,
    ));
    ref.invalidate(communityCommentsProvider(widget.post.id));
    ref.invalidate(communityPostsProvider((role: ref.read(currentUserProvider).role.name, scopeFilter: null)));
    _commentController.clear();
    if (mounted) setState(() {});
  }
}

class _PostContent extends StatelessWidget {
  final CommunityPost post;

  const _PostContent({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUrgent = post.priority == CommunityPostPriority.urgent;

    return Column(
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
            Text('${post.authorName} • ${post.authorRole}', style: theme.textTheme.labelMedium),
            const Spacer(),
            Text(_timeAgo(post.createdAt), style: theme.textTheme.labelSmall),
          ],
        ),
        const SizedBox(height: 12),
        Text(post.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(post.body, style: theme.textTheme.bodyLarge),
      ],
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
            child: Text(comment.authorName.substring(0, 1).toUpperCase()),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comment.authorName, style: t.textTheme.labelLarge),
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
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
