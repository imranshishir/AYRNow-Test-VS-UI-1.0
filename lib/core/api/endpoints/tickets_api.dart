import 'package:dio/dio.dart';
import 'package:ayrnow/core/api/models/page_response.dart';

class TicketsApi {
  final Dio _dio;

  TicketsApi(this._dio);

  Future<PageResponse<Map<String, dynamic>>> list({
    int page = 0,
    int size = 20,
    String? unitId,
    String? status,
  }) async {
    final q = <String, dynamic>{'page': page, 'size': size};
    if (unitId != null) q['unitId'] = unitId;
    if (status != null) q['status'] = status;
    final res = await _dio.get('/api/v1/tickets', queryParameters: q);
    return PageResponse.fromJson(
      res.data as Map<String, dynamic>,
      (e) => e as Map<String, dynamic>,
    );
  }
}
