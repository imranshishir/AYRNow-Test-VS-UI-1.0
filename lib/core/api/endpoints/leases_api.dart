import 'package:dio/dio.dart';

class LeasesApi {
  final Dio _dio;

  LeasesApi(this._dio);

  Future<Map<String, dynamic>> getActive() async {
    final res = await _dio.get('/api/v1/leases/me/active');
    return res.data as Map<String, dynamic>;
  }
}
