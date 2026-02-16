import 'package:firebase_auth/firebase_auth.dart';
import 'package:ayrnow/core/backend/models/app_user.dart';
import 'package:ayrnow/core/backend/repositories/user_repo.dart';
import 'package:ayrnow/core/backend/repositories/account_repo.dart';
import 'package:ayrnow/core/backend/repositories/membership_repo.dart';

/// Maps UserRole to Firestore roleType strings.
String roleTypeFromUserRole(dynamic role) {
  final str = role.toString().split('.').last;
  switch (str) {
    case 'landlord':
      return 'landlord';
    case 'tenant':
      return 'tenant';
    case 'contractor':
      return 'contractor';
    case 'guard':
      return 'security';
    default:
      return 'tenant';
  }
}

class FirebaseAuthService {
  FirebaseAuthService({
    required UserRepo userRepo,
    required AccountRepo accountRepo,
    required MembershipRepo membershipRepo,
  })  : _userRepo = userRepo,
        _accountRepo = accountRepo,
        _membershipRepo = membershipRepo;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepo _userRepo;
  final AccountRepo _accountRepo;
  final MembershipRepo _membershipRepo;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> register({
    required String email,
    required String password,
    required String displayName,
    required String roleType,
  }) async {
    final uc = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = uc.user!;
    final uid = user.uid;

    final accountId = await _accountRepo.createAccountForOwner(
      uid,
      displayName.isEmpty ? 'My Account' : "$displayName's Account",
    );

    await _membershipRepo.createOwnerMembership(
      accountId,
      uid,
      roleType: roleType,
      scope: 'fullAccess',
    );

    final now = DateTime.now();
    final appUser = AppUser(
      uid: uid,
      displayName: displayName,
      email: email.trim(),
      createdAt: now,
      lastLoginAt: now,
      defaultAccountId: accountId,
      defaultRole: roleType,
      defaultPropertyId: null,
      defaultUnitId: null,
    );
    await _userRepo.upsertUser(appUser);

    return uc;
  }

  Future<UserCredential> login(String email, String password) async {
    final uc = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = uc.user!.uid;
    final appUser = await _userRepo.getUser(uid);
    if (appUser != null) {
      await _userRepo.upsertUser(
        appUser.copyWith(lastLoginAt: DateTime.now()),
      );
    }
    return uc;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
