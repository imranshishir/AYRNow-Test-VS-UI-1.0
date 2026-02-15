import 'package:flutter/foundation.dart';
import 'package:ayrnow/features/account_management/models/managed_user_model.dart';

class MockManagedUserService extends ChangeNotifier {
  final List<ManagedUser> _users = [];

  List<ManagedUser> get users => List.unmodifiable(_users);

  /// When tenant loads their list, backfill legacy records (ownerAccountId == null and
  /// category == null, i.e. tenant household) to this tenant so they are no longer global.
  void backfillOwnerForTenant(String tenantAccountId) {
    bool changed = false;
    for (var i = 0; i < _users.length; i++) {
      final u = _users[i];
      if (u.ownerAccountId == null && u.category == null) {
        _users[i] = ManagedUser(
          id: u.id,
          fullName: u.fullName,
          email: u.email,
          roleLabel: u.roleLabel,
          permissionLabel: u.permissionLabel,
          status: u.status,
          roleType: u.roleType,
          category: u.category,
          permissionScope: u.permissionScope,
          isActive: u.isActive,
          createdAt: u.createdAt,
          ownerAccountId: tenantAccountId,
        );
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  Future<List<ManagedUser>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_users);
  }

  Future<void> addUser(ManagedUser user) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _users.add(user);
    notifyListeners();
  }

  Future<void> removeUser(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _users.removeWhere((u) => u.id == id);
    notifyListeners();
  }
}
