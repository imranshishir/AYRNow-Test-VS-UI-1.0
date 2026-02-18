import 'package:flutter/foundation.dart';

/// Scope of a community post: property, unit, or global.
enum CommunityScopeType {
  property,
  unit,
  global,
}

extension CommunityScopeTypeX on CommunityScopeType {
  String get label {
    switch (this) {
      case CommunityScopeType.property:
        return 'Property';
      case CommunityScopeType.unit:
        return 'Unit';
      case CommunityScopeType.global:
        return 'Global';
    }
  }
}

/// Priority of a post (info or urgent).
enum CommunityPostPriority {
  info,
  urgent,
}

extension CommunityPostPriorityX on CommunityPostPriority {
  String get label {
    switch (this) {
      case CommunityPostPriority.info:
        return 'Info';
      case CommunityPostPriority.urgent:
        return 'Urgent';
    }
  }
}

/// Audience: tenants only or everyone.
enum CommunityAudience {
  tenants,
  all,
}

extension CommunityAudienceX on CommunityAudience {
  String get label {
    switch (this) {
      case CommunityAudience.tenants:
        return 'Tenants only';
      case CommunityAudience.all:
        return 'Everyone';
    }
  }
}

@immutable
class CommunityPost {
  final String id;
  final CommunityScopeType scopeType;
  final String? scopeId;
  final String authorId;
  final String authorName;
  final String authorRole;
  final String title;
  final String body;
  final DateTime createdAt;
  final int commentCount;
  final CommunityPostPriority priority;
  final CommunityAudience audience;

  const CommunityPost({
    required this.id,
    required this.scopeType,
    this.scopeId,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.title,
    required this.body,
    required this.createdAt,
    this.commentCount = 0,
    this.priority = CommunityPostPriority.info,
    this.audience = CommunityAudience.all,
  });

  CommunityPost copyWith({
    String? id,
    CommunityScopeType? scopeType,
    String? scopeId,
    String? authorId,
    String? authorName,
    String? authorRole,
    String? title,
    String? body,
    DateTime? createdAt,
    int? commentCount,
    CommunityPostPriority? priority,
    CommunityAudience? audience,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      scopeType: scopeType ?? this.scopeType,
      scopeId: scopeId ?? this.scopeId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      commentCount: commentCount ?? this.commentCount,
      priority: priority ?? this.priority,
      audience: audience ?? this.audience,
    );
  }
}

@immutable
class CommunityComment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String body;
  final DateTime createdAt;

  const CommunityComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.body,
    required this.createdAt,
  });
}
