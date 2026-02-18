import 'package:dio/dio.dart';

/// Lease from backend /api/v1/leases/me/active
class LeaseResponse {
  final String id;
  final String accountId;
  final String unitId;
  final String status;
  final String? startDate;
  final String? endDate;
  final String? createdAt;

  LeaseResponse({
    required this.id,
    required this.accountId,
    required this.unitId,
    required this.status,
    this.startDate,
    this.endDate,
    this.createdAt,
  });

  factory LeaseResponse.fromJson(Map<String, dynamic> json) {
    return LeaseResponse(
      id: json['id']?.toString() ?? '',
      accountId: json['accountId']?.toString() ?? '',
      unitId: json['unitId']?.toString() ?? '',
      status: json['status'] as String? ?? 'active',
      startDate: json['startDate']?.toString(),
      endDate: json['endDate']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class LeasesApi {
  final Dio _dio;

  LeasesApi(this._dio);

  /// Returns active lease or null if 404.
  Future<LeaseResponse?> getActiveOrNull() async {
    try {
      final res = await _dio.get('/api/v1/leases/me/active');
      return LeaseResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<LeaseResponse> getActive() async {
    final res = await _dio.get('/api/v1/leases/me/active');
    return LeaseResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
