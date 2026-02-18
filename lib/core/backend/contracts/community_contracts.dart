// Backend-ready request/response contracts for community features.
// No networking - types only for future REST alignment.

class CreatePostRequest {
  final String scopeType;
  final String scopeId;
  final String audience;
  final String priority;
  final String title;
  final String body;

  const CreatePostRequest({
    required this.scopeType,
    required this.scopeId,
    required this.audience,
    required this.priority,
    required this.title,
    required this.body,
  });
}

class CreatePostResponse {
  final String postId;

  const CreatePostResponse({required this.postId});
}

class AddCommentRequest {
  final String body;

  const AddCommentRequest({required this.body});
}

class AddCommentResponse {
  final String commentId;

  const AddCommentResponse({required this.commentId});
}
