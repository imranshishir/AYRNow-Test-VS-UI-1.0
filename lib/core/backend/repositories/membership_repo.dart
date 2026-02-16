import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ayrnow/core/backend/models/membership.dart';

class MembershipRepo {
  MembershipRepo(this._firestore);

  final FirebaseFirestore _firestore;

  Future<Membership?> getMyMembership(String accountId, String uid) async {
    final q = await _firestore
        .collection('accounts')
        .doc(accountId)
        .collection('memberships')
        .where('uid', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (q.docs.isEmpty) return null;
    final doc = q.docs.first;
    return Membership.fromFirestore(
      doc as DocumentSnapshot<Map<String, dynamic>>,
      accountId,
    );
  }

  Future<void> createOwnerMembership(
    String accountId,
    String ownerUid, {
    String roleType = 'landlord',
    String scope = 'fullAccess',
  }) async {
    final ref = _firestore
        .collection('accounts')
        .doc(accountId)
        .collection('memberships')
        .doc();
    await ref.set({
      'uid': ownerUid,
      'roleType': roleType,
      'permissionScope': scope,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
      'createdByUid': ownerUid,
    });
  }
}
