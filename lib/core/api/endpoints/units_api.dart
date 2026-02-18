import 'package:dio/dio.dart';

class UnitResponse {
  final String id;
  final String accountId;
  final String propertyId;
  final String unitLabel;
  final String status;
  final String? createdAt;

  UnitResponse({
    required this.id,
    required this.accountId,
    required this.propertyId,
    required this.unitLabel,
    required this.status,
    this.createdAt,
  });

  factory UnitResponse.fromJson(Map<String, dynamic> json) {
    return UnitResponse(
      id: json['id']?.toString() ?? '',
      accountId: json['accountId']?.toString() ?? '',
      propertyId: json['propertyId']?.toString() ?? '',
      unitLabel: json['unitLabel'] as String? ?? '',
      status: json['status'] as String? ?? 'vacant',
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class UnitsApi {
  final Dio _dio;

  UnitsApi(this._dio);

  Future<List<UnitResponse>> listByProperty(String propertyId) async {
    final res = await _dio.get('/api/v1/properties/$propertyId/units');
    final list = res.data as List? ?? [];
    return list.map((e) => UnitResponse.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<UnitResponse> getById(String unitId) async {
    final res = await _dio.get('/api/v1/units/$unitId');
    return UnitResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<UnitResponse> create(String propertyId,
      {required String unitLabel, String status = 'vacant'}) async {
    final res = await _dio.post(
      '/api/v1/properties/$propertyId/units',
      data: {'unitLabel': unitLabel, 'status': status},
    );
    return UnitResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
