import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ayrnow/core/backend/firestore_paths.dart';

class AccountRepo {
  AccountRepo(this._firestore);

  final FirebaseFirestore _firestore;

  Future<String> createAccountForOwner(String ownerUid, String name) async {
    final ref = _firestore.collection('accounts').doc();
    await ref.set({
      'name': name,
      'ownerUid': ownerUid,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'active',
    });
    return ref.id;
  }

  Future<Map<String, dynamic>?> getAccount(String accountId) async {
    final doc = await _firestore.doc(FirestorePaths.account(accountId)).get();
    return doc.exists ? doc.data() : null;
  }
}
