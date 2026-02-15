import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/core/backend/models/membership.dart';
import 'package:ayrnow/core/backend/providers/use_firebase_backend_provider.dart';
import 'package:ayrnow/core/backend/repos/lease_repo.dart';
import 'package:ayrnow/core/backend/repositories/user_repo.dart';
import 'package:ayrnow/core/backend/repositories/membership_repo.dart';
import 'package:ayrnow/core/backend/services/firebase_auth_service.dart';
import 'package:ayrnow/core/models/user_role.dart';
import 'package:ayrnow/core/session/tenant_context.dart';
import 'package:ayrnow/state/role_provider.dart';

/// Maps Firestore roleType to UserRole enum.
UserRole userRoleFromString(String? roleType) {
  switch (roleType?.toLowerCase()) {
    case 'landlord':
      return UserRole.landlord;
    case 'tenant':
    case 'cotenant':
    case 'family':
      return UserRole.tenant;
    case 'contractor':
      return UserRole.contractor;
    case 'security':
    case 'guard':
      return UserRole.guard;
    default:
      return UserRole.tenant;
  }
}

/// Listens to auth changes and syncs session state (isLoggedIn, currentRole, tenantContext).
class AppSessionService {
  AppSessionService({
    required FirebaseAuthService authService,
    required UserRepo userRepo,
    required MembershipRepo membershipRepo,
    required LeaseRepo leaseRepo,
    required Ref ref,
  })  : _authService = authService,
        _userRepo = userRepo,
        _membershipRepo = membershipRepo,
        _leaseRepo = leaseRepo,
        _ref = ref;

  final FirebaseAuthService _authService;
  final UserRepo _userRepo;
  final MembershipRepo _membershipRepo;
  final LeaseRepo _leaseRepo;
  final Ref _ref;
  StreamSubscription<User?>? _sub;

  static const String _placeholderProperty = 'p1';
  static const String _placeholderUnit = 'u1';

  static bool _isTenantishRole(dynamic roleType) {
    if (roleType == null) return false;
    final s = roleType is String ? roleType : roleType.toString();
    return s == 'tenant' ||
        s == 'family' ||
        s == 'coTenant' ||
        s == 'cotenant' ||
        s == 'co_tenant';
  }

  void start() {
    _sub?.cancel();
    final useFirebase = _ref.read(useFirebaseBackendProvider);
    try {
      _sub = _authService.authStateChanges.listen(_onAuthStateChanged);
    } catch (e) {
      if (useFirebase) rethrow;
      // Firebase not configured; mock auth will set state manually
    }
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _ref.read(isLoggedInProvider.notifier).state = false;
      _ref.read(hasChosenRoleProvider.notifier).state = false;
      _ref.read(currentRoleProvider.notifier).state = UserRole.landlord;
      _ref.read(tenantContextProvider.notifier).setContext(
            const TenantContext(
              tenantAccountId: 'tenant-demo',
              selectedPropertyId: 'p1',
              selectedUnitId: 'u1',
            ),
          );
      return;
    }

    final appUser = await _userRepo.getUser(user.uid);
    if (appUser == null) {
      _ref.read(isLoggedInProvider.notifier).state = true;
      _ref.read(hasChosenRoleProvider.notifier).state = false;
      _ref.read(currentRoleProvider.notifier).state = UserRole.tenant;
      _ref.read(tenantContextProvider.notifier).setContext(
            const TenantContext(
              tenantAccountId: 'unknown',
              selectedPropertyId: _placeholderProperty,
              selectedUnitId: _placeholderUnit,
            ),
          );
      return;
    }

    final accountId = appUser.defaultAccountId ?? 'unknown';
    Membership? membership;
    if (accountId != 'unknown') {
      membership = await _membershipRepo.getMyMembership(accountId, user.uid);
    }

    final role = membership != null
        ? userRoleFromString(membership.roleType)
        : userRoleFromString(appUser.defaultRole);

    final roleTypeRaw = membership?.roleType ?? appUser.defaultRole;

    String propId = appUser.defaultPropertyId ?? _placeholderProperty;
    String unitId = appUser.defaultUnitId ?? _placeholderUnit;

    final useFirebase = _ref.read(useFirebaseBackendProvider);
    final isTenantish = _isTenantishRole(roleTypeRaw);

    if (useFirebase && isTenantish && accountId != 'unknown') {
      final lease = await _leaseRepo.getMyActiveLease(accountId, user.uid);
      if (lease != null && lease.isActive) {
        propId = lease.propertyId;
        unitId = lease.unitId;
      }
    }

    _ref.read(isLoggedInProvider.notifier).state = true;
    _ref.read(hasChosenRoleProvider.notifier).state = true;
    _ref.read(currentRoleProvider.notifier).state = role;
    _ref.read(tenantContextProvider.notifier).setContext(
          TenantContext(
            tenantAccountId: accountId,
            selectedPropertyId: propId.isEmpty ? _placeholderProperty : propId,
            selectedUnitId: unitId.isEmpty ? _placeholderUnit : unitId,
          ),
        );
  }
}
