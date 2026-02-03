class TenantProperty {
  final String id;
  final String name;
  final String address;
  final List<TenantUnit> units;

  const TenantProperty({
    required this.id,
    required this.name,
    required this.address,
    required this.units,
  });
}

class TenantUnit {
  final String id;
  final String label; // e.g., Apt 2B / Store 12
  final int rentCents;
  final String dueDateLabel; // keep demo simple
  final bool isOverdue;

  const TenantUnit({
    required this.id,
    required this.label,
    required this.rentCents,
    required this.dueDateLabel,
    required this.isOverdue,
  });
}

class TenantTicket {
  final String id;
  final String title;
  final String category;
  final String status; // Open / In Progress / Done
  final String createdLabel;
  final String description;

  const TenantTicket({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.createdLabel,
    required this.description,
  });
}

String money(int cents) => '\$' + (cents / 100).toStringAsFixed(2);
