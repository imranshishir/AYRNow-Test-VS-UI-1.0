import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ayrnow/core/backend/firestore_paths.dart';
import 'package:ayrnow/core/backend/models/lease.dart';

class LeaseRepo {
  LeaseRepo(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<Lease>> streamLeases(String accountId) {
    return _firestore
        .collection(FirestorePaths.leases(accountId))
        .snapshots()
        .map((s) => s.docs
            .map((d) => Lease.fromDoc(d as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  /// Returns the first active lease for the tenant in the account.
  /// Query: tenantUids array-contains uid, status == "active", limit 1.
  Future<Lease?> getMyActiveLease(String accountId, String uid) async {
    final q = await _firestore
        .collection(FirestorePaths.leases(accountId))
        .where('tenantUids', arrayContains: uid)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (q.docs.isEmpty) return null;
    return Lease.fromDoc(q.docs.first);
  }
}
