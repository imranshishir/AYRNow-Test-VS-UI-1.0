import '../../features/community/models/community_models.dart';

/// Backend-ready interface for community posts and comments.
abstract class CommunityRepo {
  /// [scopeFilter] null = all, 'property' = property scope, 'unit' = unit scope.
  Future<List<CommunityPost>> listPosts({
    required String role,
    String? scopeFilter,
  });

  Future<List<CommunityComment>> listComments(String postId);

  Future<void> createPost(CommunityPost draft);

  Future<void> addComment(String postId, String body);
}
