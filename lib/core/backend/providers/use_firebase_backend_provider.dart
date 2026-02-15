import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

/// True if Firebase is configured and we should use Firebase Auth/Firestore.
final useFirebaseBackendProvider = Provider<bool>((ref) {
  try {
    Firebase.app();
    return true;
  } catch (_) {
    return false;
  }
});
