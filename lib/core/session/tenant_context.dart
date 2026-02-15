import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lightweight tenant session context (mock for now).
/// Scopes tenant UI to a single property/unit.
class TenantContext {
  final String tenantAccountId;
  final String selectedPropertyId;
  final String selectedUnitId;

  const TenantContext({
    required this.tenantAccountId,
    required this.selectedPropertyId,
    required this.selectedUnitId,
  });

  TenantContext copyWith({
    String? tenantAccountId,
    String? selectedPropertyId,
    String? selectedUnitId,
  }) {
    return TenantContext(
      tenantAccountId: tenantAccountId ?? this.tenantAccountId,
      selectedPropertyId: selectedPropertyId ?? this.selectedPropertyId,
      selectedUnitId: selectedUnitId ?? this.selectedUnitId,
    );
  }
}

/// Mock default: single tenant account, first property/unit selected.
const TenantContext _defaultTenantContext = TenantContext(
  tenantAccountId: 'tenant-demo',
  selectedPropertyId: 'p1',
  selectedUnitId: 'u1',
);

final tenantContextProvider =
    StateNotifierProvider<TenantContextNotifier, TenantContext>((ref) {
  return TenantContextNotifier();
});

class TenantContextNotifier extends StateNotifier<TenantContext> {
  TenantContextNotifier() : super(_defaultTenantContext);

  void setContext(TenantContext ctx) {
    state = ctx;
  }

  void selectProperty(String propertyId) {
    state = state.copyWith(selectedPropertyId: propertyId, selectedUnitId: '');
  }

  void selectUnit(String unitId) {
    state = state.copyWith(selectedUnitId: unitId);
  }
}

/// Landlord account id for mock scoping (used when adding landlord delegation users).
const String kLandlordAccountId = 'landlord-demo';
