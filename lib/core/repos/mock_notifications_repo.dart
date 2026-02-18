import '../../features/notifications/models/notification_models.dart';
import 'notifications_repo.dart';

class MockNotificationsRepo implements NotificationsRepo {
  final List<AppNotification> _notifications = [];

  MockNotificationsRepo() {
    _notifications.addAll([
      AppNotification(
        id: 'n1',
        type: NotificationType.announcement,
        title: 'Community update',
        body: 'New building newsletter available.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        route: '/community',
        targetRole: NotificationTargetRole.any,
      ),
      AppNotification(
        id: 'n2',
        type: NotificationType.transferRequest,
        title: 'New transfer request',
        body: 'A tenant requested a profile transfer.',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: true,
        route: '/L-45',
        targetRole: NotificationTargetRole.landlord,
      ),
    ]);
  }

  @override
  Future<List<AppNotification>> list({bool unreadOnly = false}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    var list = List<AppNotification>.from(_notifications);
    if (unreadOnly) list = list.where((n) => !n.isRead).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<int> unreadCount() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _notifications.where((n) => !n.isRead).length;
  }

  @override
  Future<void> markRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx >= 0) _notifications[idx] = _notifications[idx].copyWith(isRead: true);
  }

  @override
  Future<void> markAllRead() async {
    await Future.delayed(const Duration(milliseconds: 150));
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }
}
