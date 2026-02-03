enum InvitePermission { viewOnly, billing, full }

extension InvitePermissionX on InvitePermission {
  String get label => switch (this) {
        InvitePermission.viewOnly => 'View-only',
        InvitePermission.billing => 'Billing',
        InvitePermission.full => 'Full',
      };

  String get description => switch (this) {
        InvitePermission.viewOnly => 'Can view lease, tickets, and activity.',
        InvitePermission.billing => 'Can view and manage billing + receipts.',
        InvitePermission.full => 'Can manage billing and maintenance actions.',
      };
}

enum InviteStatus { pending, accepted, declined, cancelled, expired }

extension InviteStatusX on InviteStatus {
  String get label => switch (this) {
        InviteStatus.pending => 'Pending',
        InviteStatus.accepted => 'Accepted',
        InviteStatus.declined => 'Declined',
        InviteStatus.cancelled => 'Cancelled',
        InviteStatus.expired => 'Expired',
      };
}

class PendingInvite {
  final String id;
  final String code;
  final String propertyId;
  final String propertyName;
  final String unitId;
  final String unitName;
  final String contact;
  final InvitePermission permission;
  final InviteStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? respondedAt;
  final int sentCount;
  final DateTime lastSentAt;

  const PendingInvite({
    required this.id,
    required this.code,
    required this.propertyId,
    required this.propertyName,
    required this.unitId,
    required this.unitName,
    required this.contact,
    required this.permission,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    required this.respondedAt,
    required this.sentCount,
    required this.lastSentAt,
  });

  bool get isPending => status == InviteStatus.pending;
  bool get isExpiredByTime => DateTime.now().isAfter(expiresAt);

  PendingInvite copyWith({
    InvitePermission? permission,
    InviteStatus? status,
    DateTime? respondedAt,
    int? sentCount,
    DateTime? lastSentAt,
  }) {
    return PendingInvite(
      id: id,
      code: code,
      propertyId: propertyId,
      propertyName: propertyName,
      unitId: unitId,
      unitName: unitName,
      contact: contact,
      permission: permission ?? this.permission,
      status: status ?? this.status,
      createdAt: createdAt,
      expiresAt: expiresAt,
      respondedAt: respondedAt ?? this.respondedAt,
      sentCount: sentCount ?? this.sentCount,
      lastSentAt: lastSentAt ?? this.lastSentAt,
    );
  }
}

class TenantUnitAccess {
  final String inviteCode;
  final String propertyId;
  final String propertyName;
  final String unitId;
  final String unitName;
  final String contact;
  final InvitePermission permission;
  final DateTime activatedAt;

  const TenantUnitAccess({
    required this.inviteCode,
    required this.propertyId,
    required this.propertyName,
    required this.unitId,
    required this.unitName,
    required this.contact,
    required this.permission,
    required this.activatedAt,
  });
}
