import '../../features/notifications/models/notification_models.dart';

abstract class NotificationsRepo {
  Future<List<AppNotification>> list({bool unreadOnly = false});
  Future<int> unreadCount();
  Future<void> markRead(String id);
  Future<void> markAllRead();
}
