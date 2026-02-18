import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Feature flags for switching mock vs real API per module.
/// When true, use real backend; when false, use mock.
class FeatureFlags {
  final bool auth;
  final bool properties;
  final bool units;
  final bool leases;
  final bool invites;
  final bool tickets;
  final bool contractors;
  final bool community;
  final bool security;
  final bool ledger;
  final bool tenantProfile;

  const FeatureFlags({
    this.auth = false,
    this.properties = false,
    this.units = false,
    this.leases = false,
    this.invites = false,
    this.tickets = false,
    this.contractors = false,
    this.community = false,
    this.security = false,
    this.ledger = false,
    this.tenantProfile = false,
  });

  FeatureFlags copyWith({
    bool? auth,
    bool? properties,
    bool? units,
    bool? leases,
    bool? invites,
    bool? tickets,
    bool? contractors,
    bool? community,
    bool? security,
    bool? ledger,
    bool? tenantProfile,
  }) {
    return FeatureFlags(
      auth: auth ?? this.auth,
      properties: properties ?? this.properties,
      units: units ?? this.units,
      leases: leases ?? this.leases,
      invites: invites ?? this.invites,
      tickets: tickets ?? this.tickets,
      contractors: contractors ?? this.contractors,
      community: community ?? this.community,
      security: security ?? this.security,
      ledger: ledger ?? this.ledger,
      tenantProfile: tenantProfile ?? this.tenantProfile,
    );
  }

  /// All real-API flags off (default: mock)
  static const allMock = FeatureFlags();

  /// Auth + Properties + Units enabled (first integration)
  static const authAndProperties = FeatureFlags(
    auth: true,
    properties: true,
    units: true,
  );

  /// All real API — no mock. Use Spring Boot backend.
  static const allReal = FeatureFlags(
    auth: true,
    properties: true,
    units: true,
    leases: true,
    invites: true,
    tickets: true,
    contractors: true,
    community: true,
    security: true,
    ledger: true,
    tenantProfile: true,
  );
}

final featureFlagsProvider = StateProvider<FeatureFlags>((ref) {
  return FeatureFlags.allReal;
});
