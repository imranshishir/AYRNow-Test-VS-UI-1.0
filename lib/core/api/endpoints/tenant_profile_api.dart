import 'package:dio/dio.dart';

class TenantProfileApi {
  final Dio _dio;

  TenantProfileApi(this._dio);

  Future<Map<String, dynamic>> getMyProfile() async {
    final res = await _dio.get('/api/v1/tenant-profile/me');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createExport() async {
    final res = await _dio.post('/api/v1/tenant-profile/me/export');
    return res.data as Map<String, dynamic>;
  }

  Future<void> revokeExport(String exportId) async {
    await _dio.post('/api/v1/tenant-profile/me/exports/$exportId/revoke');
  }

  Future<Map<String, dynamic>> viewShare(String shareToken) async {
    final res = await _dio.get(
      '/api/v1/tenant-profile/share/$shareToken',
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> requestReview(String shareToken) async {
    final res = await _dio.post(
      '/api/v1/tenant-profile/share/$shareToken/request-review',
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> approveRequest(String requestId) async {
    final res = await _dio.post(
      '/api/v1/tenant-profile/requests/$requestId/approve',
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> rejectRequest(String requestId) async {
    final res = await _dio.post(
      '/api/v1/tenant-profile/requests/$requestId/reject',
    );
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> importSummary(String shareToken) async {
    final res = await _dio.post(
      '/api/v1/tenant-profile/share/$shareToken/import',
    );
    return res.data as Map<String, dynamic>;
  }
}
