import 'package:flutter/material.dart';
import '../models/community_models.dart';

class CommunityPostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback? onPinToggle;

  const CommunityPostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onLike,
    required this.onPinToggle,
  });

  String _badgeText(CommunityPostType t) {
    switch (t) {
      case CommunityPostType.announcement:
        return 'Announcement';
      case CommunityPostType.alert:
        return 'Alert';
      case CommunityPostType.post:
        return 'Post';
      case CommunityPostType.event:
        return 'Event';
    }
  }

  IconData _badgeIcon(CommunityPostType t) {
    switch (t) {
      case CommunityPostType.announcement:
        return Icons.campaign_outlined;
      case CommunityPostType.alert:
        return Icons.warning_amber_rounded;
      case CommunityPostType.post:
        return Icons.forum_outlined;
      case CommunityPostType.event:
        return Icons.celebration_outlined;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final headline = (post.title?.trim().isNotEmpty ?? false)
        ? post.title!.trim()
        : post.body.trim();

    final subtitle = (post.title?.trim().isNotEmpty ?? false)
        ? post.body.trim()
        : null;

    return Card(
      elevation: 0,
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
                  Icon(_badgeIcon(post.type), size: 18),
                  const SizedBox(width: 6),
                  Text(_badgeText(post.type), style: theme.textTheme.labelLarge),
                  const SizedBox(width: 8),
                  if (post.isPinned) const Icon(Icons.push_pin, size: 16),
                  const Spacer(),
                  Text(_timeAgo(post.createdAt), style: theme.textTheme.labelMedium),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                headline,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(post.scope.label), visualDensity: VisualDensity.compact),
                  Chip(label: Text(post.author.name), visualDensity: VisualDensity.compact),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onLike,
                    icon: Icon(post.iLiked ? Icons.thumb_up : Icons.thumb_up_outlined, size: 18),
                    label: Text('${post.likeCount}'),
                  ),
                  const SizedBox(width: 6),
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.mode_comment_outlined, size: 18),
                    label: Text('${post.commentCount}'),
                  ),
                  const Spacer(),
                  if (onPinToggle != null)
                    IconButton(
                      tooltip: post.isPinned ? 'Unpin' : 'Pin',
                      onPressed: onPinToggle,
                      icon: Icon(post.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
