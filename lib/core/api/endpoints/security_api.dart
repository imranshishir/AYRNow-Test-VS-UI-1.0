import 'package:dio/dio.dart';

class SecurityApi {
  final Dio _dio;

  SecurityApi(this._dio);

  Future<Map<String, dynamic>> getSecuritySettings(String propertyId) async {
    final res = await _dio.get(
      '/api/v1/properties/$propertyId/security-settings',
    );
    return res.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listVisitors({
    String? propertyId,
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final q = <String, dynamic>{'page': page, 'size': size};
    if (propertyId != null) q['propertyId'] = propertyId;
    if (status != null) q['status'] = status;
    final res = await _dio.get('/api/v1/visitors', queryParameters: q);
    final list = (res.data is Map && res.data['content'] != null)
        ? (res.data['content'] as List)
        : (res.data as List? ?? []);
    return list.cast<Map<String, dynamic>>();
  }
}
