class RentItem {
  final String tenantName;
  final String unit;
  final double amountDue;
  final DateTime dueDate;
  final String status; // Paid/Late/Partial/Manual/Pending

  const RentItem({
    required this.tenantName,
    required this.unit,
    required this.amountDue,
    required this.dueDate,
    required this.status,
  });
}
