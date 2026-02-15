import 'package:cloud_firestore/cloud_firestore.dart';

/// Membership doc at accounts/{accountId}/memberships/{membershipId}.
class Membership {
  final String membershipId;
  final String accountId;
  final String uid;
  final String roleType;
  final String permissionScope;
  final String status;
  final DateTime createdAt;
  final String createdByUid;

  const Membership({
    required this.membershipId,
    required this.accountId,
    required this.uid,
    required this.roleType,
    required this.permissionScope,
    required this.status,
    required this.createdAt,
    required this.createdByUid,
  });

  factory Membership.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String accountId,
  ) {
    final d = doc.data()!;
    return Membership(
      membershipId: doc.id,
      accountId: accountId,
      uid: d['uid'] as String? ?? '',
      roleType: d['roleType'] as String? ?? 'tenant',
      permissionScope: d['permissionScope'] as String? ?? 'viewOnly',
      status: d['status'] as String? ?? 'active',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdByUid: d['createdByUid'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'roleType': roleType,
      'permissionScope': permissionScope,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdByUid': createdByUid,
    };
  }
}
