import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/community_mock_data.dart';
import '../models/community_models.dart';

class CommunityState {
  final List<CommunityPost> posts;
  final CommunityScope? selectedScope;

  const CommunityState({
    required this.posts,
    required this.selectedScope,
  });

  CommunityState copyWith({
    List<CommunityPost>? posts,
    CommunityScope? selectedScope,
  }) {
    return CommunityState(
      posts: posts ?? this.posts,
      selectedScope: selectedScope,
    );
  }
}

class CommunityStore extends StateNotifier<CommunityState> {
  CommunityStore()
      : super(CommunityState(
          posts: CommunityMockData.initialPosts(),
          selectedScope: null,
        ));

  void setScope(CommunityScope? scope) {
    state = state.copyWith(selectedScope: scope);
  }

  List<CommunityPost> get visiblePosts {
    final scope = state.selectedScope;
    final base = scope == null
        ? state.posts
        : state.posts.where((p) => p.scope.id == scope.id && p.scope.type == scope.type).toList();

    // pinned first, then alerts/announcements, then newest
    base.sort((a, b) {
      final pin = (b.isPinned ? 1 : 0) - (a.isPinned ? 1 : 0);
      if (pin != 0) return pin;

      final aPriority = (a.type == CommunityPostType.alert || a.type == CommunityPostType.announcement) ? 1 : 0;
      final bPriority = (b.type == CommunityPostType.alert || b.type == CommunityPostType.announcement) ? 1 : 0;
      final pr = bPriority - aPriority;
      if (pr != 0) return pr;

      return b.createdAt.compareTo(a.createdAt);
    });
    return base;
  }

  void toggleLike(String postId) {
    final updated = state.posts.map((p) {
      if (p.id != postId) return p;
      final nextLiked = !p.iLiked;
      final nextCount = nextLiked ? p.likeCount + 1 : (p.likeCount - 1).clamp(0, 1 << 30);
      return p.copyWith(iLiked: nextLiked, likeCount: nextCount);
    }).toList();
    state = state.copyWith(posts: updated);
  }

  void togglePin(String postId, {required bool canPin}) {
    if (!canPin) return;
    final updated = state.posts.map((p) {
      if (p.id != postId) return p;
      return p.copyWith(isPinned: !p.isPinned);
    }).toList();
    state = state.copyWith(posts: updated);
  }

  void addPost(CommunityPost post) {
    state = state.copyWith(posts: [post, ...state.posts]);
  }

  CommunityPost? findById(String id) {
    try {
      return state.posts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

final communityStoreProvider =
    StateNotifierProvider<CommunityStore, CommunityState>((ref) => CommunityStore());
