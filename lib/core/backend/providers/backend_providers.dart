import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/core/backend/repositories/user_repo.dart';
import 'package:ayrnow/core/backend/repositories/account_repo.dart';
import 'package:ayrnow/core/backend/repositories/membership_repo.dart';
import 'package:ayrnow/core/backend/repos/property_repo.dart';
import 'package:ayrnow/core/backend/repos/unit_repo.dart';
import 'package:ayrnow/core/backend/repos/lease_repo.dart';
export 'package:ayrnow/core/backend/providers/use_firebase_backend_provider.dart';
import 'package:ayrnow/core/backend/services/firebase_auth_service.dart';
import 'package:ayrnow/core/backend/services/app_session_service.dart';

final _firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final userRepoProvider = Provider<UserRepo>((ref) {
  return UserRepo(ref.watch(_firestoreProvider));
});

final accountRepoProvider = Provider<AccountRepo>((ref) {
  return AccountRepo(ref.watch(_firestoreProvider));
});

final membershipRepoProvider = Provider<MembershipRepo>((ref) {
  return MembershipRepo(ref.watch(_firestoreProvider));
});

final propertyRepoProvider = Provider<PropertyRepo>((ref) {
  return PropertyRepo(ref.watch(_firestoreProvider));
});

final unitRepoProvider = Provider<UnitRepo>((ref) {
  return UnitRepo(ref.watch(_firestoreProvider));
});

final leaseRepoProvider = Provider<LeaseRepo>((ref) {
  return LeaseRepo(ref.watch(_firestoreProvider));
});

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService(
    userRepo: ref.watch(userRepoProvider),
    accountRepo: ref.watch(accountRepoProvider),
    membershipRepo: ref.watch(membershipRepoProvider),
  );
});

final appSessionServiceProvider = Provider<AppSessionService>((ref) {
  return AppSessionService(
    authService: ref.watch(firebaseAuthServiceProvider),
    userRepo: ref.watch(userRepoProvider),
    membershipRepo: ref.watch(membershipRepoProvider),
    leaseRepo: ref.watch(leaseRepoProvider),
    ref: ref,
  );
});
