class PropertyDto {
  PropertyDto({
    required this.id,
    required this.accountId,
    required this.name,
    this.address1,
    this.city,
    this.state,
    this.postalCode,
  });

  final String id;
  final String accountId;
  final String name;
  final String? address1;
  final String? city;
  final String? state;
  final String? postalCode;

  factory PropertyDto.fromJson(Map<String, dynamic> json) {
    return PropertyDto(
      id: json['id']?.toString() ?? '',
      accountId: json['accountId']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      address1: json['address1'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postalCode'] as String?,
    );
  }

  String get addressLine {
    final parts = [address1, city, state, postalCode].where((e) => e != null && (e as String).isNotEmpty).toList();
    return parts.isEmpty ? 'No address' : parts.join(', ');
  }
}
