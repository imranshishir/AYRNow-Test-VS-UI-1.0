import 'package:dio/dio.dart';

/// Invite from backend
class InviteResponse {
  final String id;
  final String unitId;
  final String contactType;
  final String contactValue;
  final String invitedRole;
  final String status;
  final String? expiresAt;
  final String? inviteCode;
  final String? inviteUrlToken;
  final String? joinUrl;
  final String? lastSentAt;
  final String? acceptedAt;
  final String? createdAt;

  InviteResponse({
    required this.id,
    required this.unitId,
    required this.contactType,
    required this.contactValue,
    required this.invitedRole,
    required this.status,
    this.expiresAt,
    this.inviteCode,
    this.inviteUrlToken,
    this.joinUrl,
    this.lastSentAt,
    this.acceptedAt,
    this.createdAt,
  });

  factory InviteResponse.fromJson(Map<String, dynamic> json) {
    return InviteResponse(
      id: json['id']?.toString() ?? '',
      unitId: json['unitId']?.toString() ?? '',
      contactType: json['contactType'] as String? ?? 'email',
      contactValue: json['contactValue'] as String? ?? '',
      invitedRole: json['invitedRole'] as String? ?? 'tenant',
      status: json['status'] as String? ?? 'pending',
      expiresAt: json['expiresAt']?.toString(),
      inviteCode: json['inviteCode'] as String?,
      inviteUrlToken: json['inviteUrlToken'] as String?,
      joinUrl: json['joinUrl'] as String?,
      lastSentAt: json['lastSentAt']?.toString(),
      acceptedAt: json['acceptedAt']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  bool get isPending => status == 'pending';
}

class InvitesApi {
  final Dio _dio;

  InvitesApi(this._dio);

  /// Create invite for unit. contactType: email|phone, role: tenant|family|cotenant
  Future<InviteResponse> create(String unitId, {
    required String contactType,
    required String contactValue,
    String role = 'tenant',
  }) async {
    final res = await _dio.post(
      '/api/v1/units/$unitId/invites',
      data: {
        'contactType': contactType,
        'contactValue': contactValue,
        'role': role,
      },
    );
    return InviteResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<InviteResponse>> listForUnit(String unitId, {int page = 0, int size = 20}) async {
    final res = await _dio.get(
      '/api/v1/units/$unitId/invites',
      queryParameters: {'page': page, 'size': size},
    );
    final content = res.data is Map ? (res.data['content'] as List?) ?? res.data as List : res.data as List;
    return (content).map((e) => InviteResponse.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<InviteResponse> resend(String inviteId) async {
    final res = await _dio.post('/api/v1/invites/$inviteId/resend');
    return InviteResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<InviteResponse> cancel(String inviteId) async {
    final res = await _dio.post('/api/v1/invites/$inviteId/cancel');
    return InviteResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<InviteResponse> accept(String inviteUrlToken) async {
    final res = await _dio.post('/api/v1/invites/accept/$inviteUrlToken');
    return InviteResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
