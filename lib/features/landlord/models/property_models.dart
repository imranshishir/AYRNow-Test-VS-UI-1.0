class PropertyModel {
  final String id;
  final String name;
  final String address;
  final String type; // Residential / Commercial
  final List<UnitModel> units;

  const PropertyModel({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    required this.units,
  });
}

class UnitModel {
  final String id;
  final String label; // Apt 2B / Store 12
  final String status; // Occupied / Vacant
  final TenantModel? tenant;

  const UnitModel({
    required this.id,
    required this.label,
    required this.status,
    this.tenant,
  });
}

class TenantModel {
  final String id;
  final String name;
  final String phone;
  final String leaseEnds;

  const TenantModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.leaseEnds,
  });
}
