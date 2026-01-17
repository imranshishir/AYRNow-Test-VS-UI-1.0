class GuardApproval {
  final String id;
  final String propertyName;
  final String entryPoint; // Main gate, Lobby, etc.
  final String unitLabel; // Apt 2B / Store 12
  final String visitorName;
  final String visitorType; // Guest, Delivery, Contractor
  final String etaLabel; // "Now", "10 min", "2:30 PM"
  final String status; // Pending, Approved, Denied
  final String notes;

  const GuardApproval({
    required this.id,
    required this.propertyName,
    required this.entryPoint,
    required this.unitLabel,
    required this.visitorName,
    required this.visitorType,
    required this.etaLabel,
    required this.status,
    required this.notes,
  });
}

class GuardLogEntry {
  final String time;
  final String title;
  final String subtitle;

  const GuardLogEntry(
      {required this.time, required this.title, required this.subtitle});
}
