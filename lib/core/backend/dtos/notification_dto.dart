import '../../../features/notifications/models/notification_models.dart';

class NotificationDto {
  NotificationDto({
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

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'];
    DateTime created = DateTime.now();
    if (createdAt != null) {
      if (createdAt is String) created = DateTime.tryParse(createdAt) ?? created;
      if (createdAt is int) created = DateTime.fromMillisecondsSinceEpoch(createdAt);
    }
    Map<String, String>? params;
    final p = json['params'];
    if (p is Map) {
      params = p.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
    }
    return NotificationDto(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'announcement',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: created,
      isRead: json['isRead'] as bool? ?? false,
      route: json['route'] as String?,
      params: params,
      propertyId: json['propertyId'] as String?,
      unitId: json['unitId'] as String?,
      targetRole: json['targetRole'] as String? ?? 'any',
    );
  }
}

NotificationType _parseNotificationType(String s) {
  switch (s.toLowerCase()) {
    case 'comment':
      return NotificationType.comment;
    case 'transferrequest':
    case 'transfer_request':
      return NotificationType.transferRequest;
    case 'transferdecision':
    case 'transfer_decision':
      return NotificationType.transferDecision;
    case 'householdinvite':
    case 'household_invite':
      return NotificationType.householdInvite;
    case 'householddeactivated':
    case 'household_deactivated':
      return NotificationType.householdDeactivated;
    case 'maintenanceticket':
    case 'maintenance_ticket':
      return NotificationType.maintenanceTicket;
    default:
      return NotificationType.announcement;
  }
}

NotificationTargetRole _parseTargetRole(String s) {
  switch (s.toLowerCase()) {
    case 'landlord':
      return NotificationTargetRole.landlord;
    case 'tenant':
      return NotificationTargetRole.tenant;
    default:
      return NotificationTargetRole.any;
  }
}

AppNotification notificationDtoToModel(NotificationDto dto) {
  return AppNotification(
    id: dto.id,
    type: _parseNotificationType(dto.type),
    title: dto.title,
    body: dto.body,
    createdAt: dto.createdAt,
    isRead: dto.isRead,
    route: dto.route,
    params: dto.params,
    propertyId: dto.propertyId,
    unitId: dto.unitId,
    targetRole: _parseTargetRole(dto.targetRole),
  );
}
