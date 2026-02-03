import 'package:ayrnow/features/invite/models/invite_models.dart';

class InviteMockData {
  static List<PendingInvite> seedInvites() {
    final now = DateTime.now();

    return [
      PendingInvite(
        id: 'inv-1001',
        code: 'HXA2B9',
        propertyId: 'P-1001',
        propertyName: 'Harlem Heights',
        unitId: 'A-01',
        unitName: 'Apt 01',
        contact: 'tenant.one@email.com',
        permission: InvitePermission.full,
        status: InviteStatus.pending,
        createdAt: now.subtract(const Duration(days: 1, hours: 4)),
        expiresAt: now.add(const Duration(days: 6)),
        respondedAt: null,
        sentCount: 1,
        lastSentAt: now.subtract(const Duration(days: 1, hours: 4)),
      ),
      PendingInvite(
        id: 'inv-1002',
        code: 'RVT7Q1',
        propertyId: 'P-1001',
        propertyName: 'Harlem Heights',
        unitId: 'A-02',
        unitName: 'Apt 02',
        contact: '(716) 555-3321',
        permission: InvitePermission.billing,
        status: InviteStatus.pending,
        createdAt: now.subtract(const Duration(days: 2)),
        expiresAt: now.add(const Duration(days: 5)),
        respondedAt: null,
        sentCount: 2,
        lastSentAt: now.subtract(const Duration(hours: 6)),
      ),
      PendingInvite(
        id: 'inv-1003',
        code: 'ELM4Z3',
        propertyId: 'P-2001',
        propertyName: 'Elmwood Plaza',
        unitId: 'S-04',
        unitName: 'Store 04',
        contact: 'office@elm-demo.com',
        permission: InvitePermission.viewOnly,
        status: InviteStatus.expired,
        createdAt: now.subtract(const Duration(days: 12)),
        expiresAt: now.subtract(const Duration(days: 5)),
        respondedAt: null,
        sentCount: 1,
        lastSentAt: now.subtract(const Duration(days: 12)),
      ),
    ];
  }
}
