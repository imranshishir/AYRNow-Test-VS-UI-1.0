import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ayrnow/core/backend/firestore_paths.dart';
import 'package:ayrnow/core/backend/models/property.dart';

class PropertyRepo {
  PropertyRepo(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<Property>> streamProperties(String accountId) {
    return _firestore
        .collection(FirestorePaths.properties(accountId))
        .snapshots()
        .map((s) => s.docs
            .map((d) => Property.fromDoc(d as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  Future<void> createProperty(String accountId, Property property) async {
    await _firestore
        .collection(FirestorePaths.properties(accountId))
        .doc(property.id)
        .set(property.toMap());
  }
}
