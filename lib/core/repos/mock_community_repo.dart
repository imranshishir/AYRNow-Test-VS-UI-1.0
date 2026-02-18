import 'dart:async';

import '../../features/community/models/community_models.dart';
import 'community_repo.dart';

/// In-memory mock implementation. Posts and comments persist for the session.
class MockCommunityRepo implements CommunityRepo {
  final List<CommunityPost> _posts = [];
  final Map<String, List<CommunityComment>> _commentsByPostId = {};
  bool _seeded = false;

  void _seedIfNeeded() {
    if (_seeded) return;
    _seeded = true;
    final now = DateTime.now();
    _posts.addAll([
      CommunityPost(
        id: 'post-1',
        scopeType: CommunityScopeType.property,
        scopeId: 'p1',
        authorId: 'll1',
        authorName: 'Management',
        authorRole: 'landlord',
        title: 'Water Outage Today',
        body: 'City maintenance from 2:00 PM – 5:00 PM. Please store water in advance.',
        createdAt: now.subtract(const Duration(hours: 2)),
        commentCount: 2,
        priority: CommunityPostPriority.urgent,
        audience: CommunityAudience.all,
      ),
      CommunityPost(
        id: 'post-2',
        scopeType: CommunityScopeType.property,
        scopeId: 'p1',
        authorId: 'll1',
        authorName: 'Management',
        authorRole: 'landlord',
        title: 'Lobby Painting',
        body: 'Lobby walls will be painted this weekend. Minor odor expected.',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        commentCount: 5,
        priority: CommunityPostPriority.info,
        audience: CommunityAudience.tenants,
      ),
      CommunityPost(
        id: 'post-3',
        scopeType: CommunityScopeType.unit,
        scopeId: 'u3b',
        authorId: 't1',
        authorName: 'Ayesha (Tenant)',
        authorRole: 'tenant',
        title: 'Birthday Invite',
        body: 'Hey neighbors! Join us Saturday 6 PM in the common room.',
        createdAt: now.subtract(const Duration(hours: 8)),
        commentCount: 3,
        priority: CommunityPostPriority.info,
        audience: CommunityAudience.all,
      ),
    ]);
    _commentsByPostId['post-1'] = [
      CommunityComment(
        id: 'c1',
        postId: 'post-1',
        authorId: 't2',
        authorName: 'Imran',
        body: 'Thanks for the heads up!',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 50)),
      ),
      CommunityComment(
        id: 'c2',
        postId: 'post-1',
        authorId: 't1',
        authorName: 'Ayesha',
        body: 'Will do.',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 30)),
      ),
    ];
    _commentsByPostId['post-2'] = [
      CommunityComment(
        id: 'c3',
        postId: 'post-2',
        authorId: 't1',
        authorName: 'Ayesha',
        body: 'Good to know, thanks.',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  Future<List<CommunityPost>> listPosts({
    required String role,
    String? scopeFilter,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _seedIfNeeded();

    var list = List<CommunityPost>.from(_posts);
    if (scopeFilter == 'property') {
      list = list.where((p) => p.scopeType == CommunityScopeType.property).toList();
    } else if (scopeFilter == 'unit') {
      list = list.where((p) => p.scopeType == CommunityScopeType.unit).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<List<CommunityComment>> listComments(String postId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _seedIfNeeded();
    final list = _commentsByPostId[postId] ?? [];
    return List.from(list)..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<void> createPost(CommunityPost draft) async {
    await Future.delayed(const Duration(milliseconds: 250));
    _posts.insert(0, draft);
  }

  @override
  Future<void> addComment(String postId, String body) async {
    await Future.delayed(const Duration(milliseconds: 180));
    _seedIfNeeded();
    final authorId = 'current-user';
    final authorName = 'You';
    final comment = CommunityComment(
      id: 'c-${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      body: body.trim(),
      createdAt: DateTime.now(),
    );
    final list = List<CommunityComment>.from(_commentsByPostId[postId] ?? []);
    list.add(comment);
    _commentsByPostId[postId] = list;

    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx >= 0) {
      final p = _posts[idx];
      _posts[idx] = p.copyWith(commentCount: p.commentCount + 1);
    }
  }
}
