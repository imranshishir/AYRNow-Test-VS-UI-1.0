import 'package:flutter/foundation.dart';

enum NotificationType {
  announcement,
  comment,
  transferRequest,
  transferDecision,
  householdInvite,
  householdDeactivated,
  maintenanceTicket,
}

enum NotificationTargetRole { landlord, tenant, any }

@immutable
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  final String? route;
  final Map<String, String>? params;

  final String? propertyId;
  final String? unitId;
  final NotificationTargetRole targetRole;

  const AppNotification({
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
    this.targetRole = NotificationTargetRole.any,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      route: route,
      params: params,
      propertyId: propertyId,
      unitId: unitId,
      targetRole: targetRole,
    );
  }
}
