class InviteDto {
  InviteDto({
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
  });

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

  factory InviteDto.fromJson(Map<String, dynamic> json) {
    return InviteDto(
      id: json['id']?.toString() ?? '',
      unitId: json['unitId']?.toString() ?? '',
      contactType: json['contactType'] as String? ?? '',
      contactValue: json['contactValue'] as String? ?? '',
      invitedRole: json['invitedRole'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      expiresAt: json['expiresAt']?.toString(),
      inviteCode: json['inviteCode'] as String?,
      inviteUrlToken: json['inviteUrlToken'] as String?,
      joinUrl: json['joinUrl'] as String?,
    );
  }

  /// Preferred display code for sharing: inviteCode, then inviteUrlToken, then joinUrl.
  String get displayCode => inviteCode ?? inviteUrlToken ?? joinUrl ?? '';
}

