import 'package:dio/dio.dart';

/// Property response from backend
class PropertyResponse {
  final String id;
  final String accountId;
  final String name;
  final String? address1;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? createdAt;

  PropertyResponse({
    required this.id,
    required this.accountId,
    required this.name,
    this.address1,
    this.city,
    this.state,
    this.postalCode,
    this.createdAt,
  });

  factory PropertyResponse.fromJson(Map<String, dynamic> json) {
    return PropertyResponse(
      id: json['id']?.toString() ?? '',
      accountId: json['accountId']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      address1: json['address1'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postalCode'] as String?,
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class PropertiesApi {
  final Dio _dio;

  PropertiesApi(this._dio);

  Future<List<PropertyResponse>> list() async {
    final res = await _dio.get('/api/v1/properties');
    final list = res.data as List? ?? [];
    return list
        .map((e) => PropertyResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PropertyResponse> getById(String propertyId) async {
    final res = await _dio.get('/api/v1/properties/$propertyId');
    return PropertyResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<PropertyResponse> create({
    required String name,
    String? address1,
    String? city,
    String? state,
    String? postalCode,
  }) async {
    final res = await _dio.post(
      '/api/v1/properties',
      data: {
        'name': name,
        if (address1 != null) 'address1': address1,
        if (city != null) 'city': city,
        if (state != null) 'state': state,
        if (postalCode != null) 'postalCode': postalCode,
      },
    );
    return PropertyResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
