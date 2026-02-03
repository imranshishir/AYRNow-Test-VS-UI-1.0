import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ayrnow/features/invite/data/invite_mock_data.dart';
import 'package:ayrnow/features/invite/models/invite_models.dart';

class InviteState {
  final List<PendingInvite> invites;
  final List<TenantUnitAccess> activeAccess;

  const InviteState({
    required this.invites,
    required this.activeAccess,
  });

  InviteState copyWith({
    List<PendingInvite>? invites,
    List<TenantUnitAccess>? activeAccess,
  }) {
    return InviteState(
      invites: invites ?? this.invites,
      activeAccess: activeAccess ?? this.activeAccess,
    );
  }
}

class InviteStore extends StateNotifier<InviteState> {
  InviteStore()
      : super(InviteState(
          invites: InviteMockData.seedInvites(),
          activeAccess: const [],
        ));

  List<PendingInvite> invitesForProperty(String propertyId) {
    _syncExpirations();
    return state.invites.where((x) => x.propertyId == propertyId).toList();
  }

  PendingInvite? findByCode(String code) {
    _syncExpirations();
    try {
      return state.invites.firstWhere((x) => x.code == code);
    } catch (_) {
      return null;
    }
  }

  PendingInvite createInvite({
    required String propertyId,
    required String propertyName,
    required String unitId,
    required String unitName,
    required String contact,
    required InvitePermission permission,
  }) {
    final now = DateTime.now();
    final id = 'inv-${now.microsecondsSinceEpoch}';
    final code = _generateCode(now);
    final invite = PendingInvite(
      id: id,
      code: code,
      propertyId: propertyId,
      propertyName: propertyName,
      unitId: unitId,
      unitName: unitName,
      contact: contact.trim(),
      permission: permission,
      status: InviteStatus.pending,
      createdAt: now,
      expiresAt: now.add(const Duration(days: 7)),
      respondedAt: null,
      sentCount: 1,
      lastSentAt: now,
    );

    state = state.copyWith(invites: [invite, ...state.invites]);
    return invite;
  }

  void resendInvite(String inviteId) {
    _updateInvite(inviteId, (i) {
      if (!i.isPending || i.isExpiredByTime) return i;
      final now = DateTime.now();
      return i.copyWith(sentCount: i.sentCount + 1, lastSentAt: now);
    });
  }

  void cancelInvite(String inviteId) {
    _updateInvite(inviteId, (i) {
      if (!i.isPending) return i;
      return i.copyWith(status: InviteStatus.cancelled);
    });
  }

  void expireInvite(String inviteId) {
    _updateInvite(inviteId, (i) {
      if (!i.isPending) return i;
      return i.copyWith(status: InviteStatus.expired);
    });
  }

  bool declineInvite(String code) {
    final invite = findByCode(code);
    if (invite == null || !invite.isPending || invite.isExpiredByTime) return false;

    _updateInvite(invite.id, (i) {
      return i.copyWith(
        status: InviteStatus.declined,
        respondedAt: DateTime.now(),
      );
    });
    return true;
  }

  bool acceptInvite(String code) {
    final invite = findByCode(code);
    if (invite == null || !invite.isPending || invite.isExpiredByTime) return false;

    _updateInvite(invite.id, (i) {
      return i.copyWith(
        status: InviteStatus.accepted,
        respondedAt: DateTime.now(),
      );
    });

    final alreadyAdded = state.activeAccess.any((a) => a.inviteCode == code);
    if (!alreadyAdded) {
      final access = TenantUnitAccess(
        inviteCode: invite.code,
        propertyId: invite.propertyId,
        propertyName: invite.propertyName,
        unitId: invite.unitId,
        unitName: invite.unitName,
        contact: invite.contact,
        permission: invite.permission,
        activatedAt: DateTime.now(),
      );
      state = state.copyWith(activeAccess: [access, ...state.activeAccess]);
    }

    return true;
  }

  void _syncExpirations() {
    final now = DateTime.now();
    var changed = false;
    final updated = state.invites.map((i) {
      if (i.status == InviteStatus.pending && now.isAfter(i.expiresAt)) {
        changed = true;
        return i.copyWith(status: InviteStatus.expired);
      }
      return i;
    }).toList();

    if (changed) {
      state = state.copyWith(invites: updated);
    }
  }

  void _updateInvite(String id, PendingInvite Function(PendingInvite) update) {
    final updated = state.invites.map((i) => i.id == id ? update(i) : i).toList();
    state = state.copyWith(invites: updated);
  }

  String _generateCode(DateTime now) {
    final n = now.microsecondsSinceEpoch.remainder(0xFFFFFF);
    return n.toRadixString(36).toUpperCase().padLeft(6, '0').substring(0, 6);
  }
}

final inviteStoreProvider =
    StateNotifierProvider<InviteStore, InviteState>((ref) => InviteStore());
