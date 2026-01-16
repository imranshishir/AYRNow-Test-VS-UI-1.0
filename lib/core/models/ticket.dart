class MaintenanceTicket {
  final String id;
  final String unit;
  final String title;
  final String priority; // Low/Med/High/Emergency
  final DateTime createdAt;
  final String status; // Open/Approved/Assigned/InProgress/Completed/Closed

  const MaintenanceTicket({
    required this.id,
    required this.unit,
    required this.title,
    required this.priority,
    required this.createdAt,
    required this.status,
  });
}
