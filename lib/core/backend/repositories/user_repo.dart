import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ayrnow/core/backend/firestore_paths.dart';
import 'package:ayrnow/core/backend/models/app_user.dart';

class UserRepo {
  UserRepo(this._firestore);

  final FirebaseFirestore _firestore;

  Future<AppUser?> getUser(String uid) async {
    final doc = await _firestore.doc(FirestorePaths.user(uid)).get();
    if (doc.exists && doc.data() != null) {
      return AppUser.fromFirestore(doc);
    }
    return null;
  }

  Future<void> upsertUser(AppUser user) async {
    await _firestore
        .doc(FirestorePaths.user(user.uid))
        .set(user.toFirestore(), SetOptions(merge: true));
  }
}
