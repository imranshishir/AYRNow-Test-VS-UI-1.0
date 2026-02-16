class ContractorJob {
  final String id;
  final String propertyName;
  final String unitLabel;
  final String address;
  final String category; // Plumbing, HVAC, Electrical...
  final String priority; // Low, Medium, High
  final String status; // New, Accepted, In Progress, Completed
  final String scheduledLabel;
  final String description;

  const ContractorJob({
    required this.id,
    required this.propertyName,
    required this.unitLabel,
    required this.address,
    required this.category,
    required this.priority,
    required this.status,
    required this.scheduledLabel,
    required this.description,
  });
}
