class UnitDto {
  UnitDto({
    required this.id,
    required this.accountId,
    required this.propertyId,
    required this.unitLabel,
    required this.status,
  });

  final String id;
  final String accountId;
  final String propertyId;
  final String unitLabel;
  final String status;

  factory UnitDto.fromJson(Map<String, dynamic> json) {
    return UnitDto(
      id: json['id']?.toString() ?? '',
      accountId: json['accountId']?.toString() ?? '',
      propertyId: json['propertyId']?.toString() ?? '',
      unitLabel: json['unitLabel'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

