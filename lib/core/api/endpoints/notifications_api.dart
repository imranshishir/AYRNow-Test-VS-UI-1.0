import 'package:dio/dio.dart';
import 'package:ayrnow/core/api/models/page_response.dart';

class NotificationsApi {
  final Dio _dio;

  NotificationsApi(this._dio);

  Future<PageResponse<Map<String, dynamic>>> list({
    int page = 0,
    int size = 20,
  }) async {
    final res = await _dio.get(
      '/api/v1/notifications',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      res.data as Map<String, dynamic>,
      (e) => e as Map<String, dynamic>,
    );
  }
}
