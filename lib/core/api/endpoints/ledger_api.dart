import 'package:dio/dio.dart';
import 'package:ayrnow/core/api/models/page_response.dart';

class LedgerApi {
  final Dio _dio;

  LedgerApi(this._dio);

  Future<PageResponse<Map<String, dynamic>>> listByUnit(
    String unitId, {
    int page = 0,
    int size = 20,
  }) async {
    final res = await _dio.get(
      '/api/v1/ledger/units/$unitId',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      res.data as Map<String, dynamic>,
      (e) => e as Map<String, dynamic>,
    );
  }

  Future<PageResponse<Map<String, dynamic>>> listByLease(
    String leaseId, {
    int page = 0,
    int size = 20,
  }) async {
    final res = await _dio.get(
      '/api/v1/ledger/leases/$leaseId',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      res.data as Map<String, dynamic>,
      (e) => e as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> getUnitBalance(String unitId) async {
    final res = await _dio.get('/api/v1/balances/units/$unitId');
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getLeaseBalance(String leaseId) async {
    final res = await _dio.get('/api/v1/balances/leases/$leaseId');
    return res.data as Map<String, dynamic>;
  }
}
