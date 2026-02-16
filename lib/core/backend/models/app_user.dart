import 'package:cloud_firestore/cloud_firestore.dart';

/// User profile doc at users/{uid}.
class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? defaultAccountId;
  final String? defaultRole;
  final String? defaultPropertyId;
  final String? defaultUnitId;

  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.createdAt,
    this.lastLoginAt,
    this.defaultAccountId,
    this.defaultRole,
    this.defaultPropertyId,
    this.defaultUnitId,
  });

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return AppUser(
      uid: doc.id,
      displayName: d['displayName'] as String? ?? '',
      email: d['email'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (d['lastLoginAt'] as Timestamp?)?.toDate(),
      defaultAccountId: d['defaultAccountId'] as String?,
      defaultRole: d['defaultRole'] as String?,
      defaultPropertyId: d['defaultPropertyId'] as String?,
      defaultUnitId: d['defaultUnitId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      if (lastLoginAt != null) 'lastLoginAt': Timestamp.fromDate(lastLoginAt!),
      if (defaultAccountId != null) 'defaultAccountId': defaultAccountId!,
      if (defaultRole != null) 'defaultRole': defaultRole!,
      if (defaultPropertyId != null) 'defaultPropertyId': defaultPropertyId!,
      if (defaultUnitId != null) 'defaultUnitId': defaultUnitId!,
    };
  }

  AppUser copyWith({
    String? displayName,
    String? email,
    DateTime? lastLoginAt,
    String? defaultAccountId,
    String? defaultRole,
    String? defaultPropertyId,
    String? defaultUnitId,
  }) {
    return AppUser(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      defaultAccountId: defaultAccountId ?? this.defaultAccountId,
      defaultRole: defaultRole ?? this.defaultRole,
      defaultPropertyId: defaultPropertyId ?? this.defaultPropertyId,
      defaultUnitId: defaultUnitId ?? this.defaultUnitId,
    );
  }
}
