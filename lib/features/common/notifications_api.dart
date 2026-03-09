import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/backend/api_base_url.dart';

/// Single notification from GET /v1/notifications
class NotificationItem {
  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.route,
    this.propertyId,
    this.unitId,
  });

  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime? createdAt;
  final bool isRead;
  final String? route;
  final String? propertyId;
  final String? unitId;

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'];
    DateTime? dt;
    if (createdAt != null) {
      if (createdAt is String) dt = DateTime.tryParse(createdAt);
    }
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: dt,
      isRead: json['isRead'] == true,
      route: json['route'] as String?,
      propertyId: json['propertyId']?.toString(),
      unitId: json['unitId']?.toString(),
    );
  }

  String get timeAgo {
    if (createdAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(createdAt!);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

Future<List<NotificationItem>> fetchNotifications(String? token, {bool unreadOnly = false}) async {
  final baseUrl = await resolveApiBaseUrl();
  if (token == null || token.isEmpty) return [];
  final uri = Uri.parse('$baseUrl/v1/notifications?unreadOnly=$unreadOnly');
  final res = await http.get(
    uri,
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  ).timeout(const Duration(seconds: 15));
  if (res.statusCode < 200 || res.statusCode >= 300) return [];
  if (res.body.isEmpty) return [];
  final decoded = jsonDecode(res.body);
  if (decoded is! List) return [];
  return decoded
      .whereType<Map>()
      .map((e) => NotificationItem.fromJson(e.cast<String, dynamic>()))
      .toList();
}

Future<bool> markAllNotificationsRead(String? token) async {
  final baseUrl = await resolveApiBaseUrl();
  if (token == null || token.isEmpty) return false;
  final uri = Uri.parse('$baseUrl/v1/notifications/mark-all-read');
  final res = await http.post(
    uri,
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  ).timeout(const Duration(seconds: 10));
  return res.statusCode >= 200 && res.statusCode < 300;
}
