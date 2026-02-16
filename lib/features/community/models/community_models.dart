import 'package:flutter/foundation.dart';

enum CommunityScopeType { property, building, unit }
enum CommunityPostType { alert, announcement, post, event }
enum CommunityAuthorRole { management, tenant, contractor, security }

@immutable
class CommunityScope {
  final CommunityScopeType type;
  final String id;
  final String label;
  const CommunityScope({required this.type, required this.id, required this.label});
}

@immutable
class CommunityUser {
  final String id;
  final String name;
  final CommunityAuthorRole role;
  final String? avatarUrl;
  const CommunityUser({required this.id, required this.name, required this.role, this.avatarUrl});

  String get roleLabel {
    switch (role) {
      case CommunityAuthorRole.management: return 'Management';
      case CommunityAuthorRole.tenant: return 'Tenant';
      case CommunityAuthorRole.contractor: return 'Contractor';
      case CommunityAuthorRole.security: return 'Security';
    }
  }
}

@immutable
class CommunityAuthor extends CommunityUser {
  const CommunityAuthor({
    required super.id,
    required super.name,
    required super.role,
    super.avatarUrl,
  });
}

@immutable
class CommunityPost {
  final String id;
  final CommunityPostType type;
  final CommunityScope scope;
  final CommunityAuthor author;
  final String? title;
  final String body;
  final DateTime createdAt;
  final bool isPinned;
  final int likeCount;
  final int commentCount;
  final bool iLiked;

  const CommunityPost({
    required this.id,
    required this.type,
    required this.scope,
    required this.author,
    this.title,
    required this.body,
    required this.createdAt,
    this.isPinned = false,
    this.likeCount = 0,
    this.commentCount = 0,
    this.iLiked = false,
  });

  CommunityPost copyWith({
    String? id,
    CommunityPostType? type,
    CommunityScope? scope,
    CommunityAuthor? author,
    String? title,
    String? body,
    DateTime? createdAt,
    bool? isPinned,
    int? likeCount,
    int? commentCount,
    bool? iLiked,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      type: type ?? this.type,
      scope: scope ?? this.scope,
      author: author ?? this.author,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      iLiked: iLiked ?? this.iLiked,
    );
  }
}

@immutable
class CommunityComment {
  final String id;
  final String postId;
  final CommunityAuthor author;
  final String body;
  final DateTime createdAt;

  const CommunityComment({
    required this.id,
    required this.postId,
    required this.author,
    required this.body,
    required this.createdAt,
  });
}

@immutable
class CommunityNotificationItem {
  final String id;
  final String title;
  final String? message;
  final String? subtitle;
  final String? postId;
  final DateTime createdAt;
  final CommunityScope? scope;
  const CommunityNotificationItem({
    required this.id,
    required this.title,
    this.message,
    this.subtitle,
    this.postId,
    required this.createdAt,
    this.scope,
  });
}
