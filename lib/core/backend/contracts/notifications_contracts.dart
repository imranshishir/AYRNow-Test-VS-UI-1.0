// Backend-ready request/response contracts for notifications.
// No networking - types only for future REST alignment.

class NotificationResponse {
  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? route;
  final Map<String, String>? params;
  final String? propertyId;
  final String? unitId;
  final String targetRole;

  const NotificationResponse({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.route,
    this.params,
    this.propertyId,
    this.unitId,
    this.targetRole = 'any',
  });
}

class MarkReadRequest {
  final String id;

  const MarkReadRequest({required this.id});
}

class MarkAllReadRequest {
  const MarkAllReadRequest();
}
