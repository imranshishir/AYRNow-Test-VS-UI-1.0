import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ayrnow/core/backend/firestore_paths.dart';
import 'package:ayrnow/core/backend/models/unit.dart';

class UnitRepo {
  UnitRepo(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<Unit>> streamUnits(String accountId, String propertyId) {
    return _firestore
        .collection(FirestorePaths.units(accountId, propertyId))
        .snapshots()
        .map((s) => s.docs
            .map((d) => Unit.fromDoc(d as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  Future<void> createUnit(
    String accountId,
    String propertyId,
    Unit unit,
  ) async {
    await _firestore
        .collection(FirestorePaths.units(accountId, propertyId))
        .doc(unit.id)
        .set(unit.toMap());
  }
}
