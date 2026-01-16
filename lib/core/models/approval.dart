class EntryApproval {
  final String id;
  final String visitorName;
  final String unit;
  final DateTime windowStart;
  final DateTime windowEnd;
  final String reason;

  const EntryApproval({
    required this.id,
    required this.visitorName,
    required this.unit,
    required this.windowStart,
    required this.windowEnd,
    required this.reason,
  });
}
