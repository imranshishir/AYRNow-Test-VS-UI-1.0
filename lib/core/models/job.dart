class ContractorJob {
  final String id;
  final String property;
  final String issue;
  final String distanceText;
  final String status; // Invited/InProgress/Completed/AwaitingApproval

  const ContractorJob({
    required this.id,
    required this.property,
    required this.issue,
    required this.distanceText,
    required this.status,
  });
}
