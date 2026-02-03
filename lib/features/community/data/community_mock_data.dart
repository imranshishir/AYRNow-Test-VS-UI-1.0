import '../models/community_models.dart';

class CommunityMockData {
  static final scopes = <CommunityScope>[
    const CommunityScope(type: CommunityScopeType.property, id: 'p1', label: 'Maple Apartments'),
    const CommunityScope(type: CommunityScopeType.building, id: 'bA', label: 'Building A'),
    const CommunityScope(type: CommunityScopeType.unit, id: 'u3b', label: 'Unit 3B'),
  ];

  static const landlord = CommunityAuthor(
    id: 'll1',
    name: 'Landlord / Management',
    role: CommunityAuthorRole.management,
  );

  static const tenantA = CommunityAuthor(
    id: 't1',
    name: 'Ayesha (Tenant)',
    role: CommunityAuthorRole.tenant,
  );

  static const tenantB = CommunityAuthor(
    id: 't2',
    name: 'Imran (Tenant)',
    role: CommunityAuthorRole.tenant,
  );

  static List<CommunityPost> initialPosts() {
    final now = DateTime.now();
    return [
      CommunityPost(
        id: 'post-1',
        type: CommunityPostType.alert,
        scope: scopes[0],
        title: 'Water Outage Today',
        body: 'City maintenance from 2:00 PM – 5:00 PM. Please store water in advance.',
        createdAt: now.subtract(const Duration(hours: 2)),
        author: landlord,
        isPinned: true,
        likeCount: 8,
        commentCount: 2,
      ),
      CommunityPost(
        id: 'post-2',
        type: CommunityPostType.announcement,
        scope: scopes[1],
        title: 'Lobby Painting',
        body: 'Lobby walls will be painted this weekend. Minor odor expected.',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        author: landlord,
        isPinned: true,
        likeCount: 12,
        commentCount: 5,
      ),
      CommunityPost(
        id: 'post-3',
        type: CommunityPostType.event,
        scope: scopes[0],
        title: 'Birthday Invite 🎉',
        body: 'Hey neighbors! Join us Saturday 6 PM in the common room for a small birthday get-together.',
        createdAt: now.subtract(const Duration(hours: 8)),
        author: tenantA,
        likeCount: 6,
        commentCount: 3,
      ),
      CommunityPost(
        id: 'post-4',
        type: CommunityPostType.post,
        scope: scopes[2],
        body: 'Package deliveries are getting mixed up. Please double-check labels before taking.',
        createdAt: now.subtract(const Duration(days: 2, hours: 4)),
        author: tenantB,
        likeCount: 3,
        commentCount: 0,
      ),
    ];
  }

  static List<CommunityNotificationItem> initialNotifications() {
    final now = DateTime.now();
    return [
      CommunityNotificationItem(
        id: 'n1',
        title: 'New alert posted',
        subtitle: 'Water Outage Today',
        createdAt: now.subtract(const Duration(hours: 1)),
        postId: 'post-1',
      ),
      CommunityNotificationItem(
        id: 'n2',
        title: 'New announcement',
        subtitle: 'Lobby Painting',
        createdAt: now.subtract(const Duration(days: 1)),
        postId: 'post-2',
      ),
      CommunityNotificationItem(
        id: 'n3',
        title: 'New community post',
        subtitle: 'Birthday Invite 🎉',
        createdAt: now.subtract(const Duration(hours: 7)),
        postId: 'post-3',
      ),
    ];
  }
}
