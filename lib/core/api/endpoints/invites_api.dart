import 'package:dio/dio.dart';

class InvitesApi {
  final Dio _dio;

  InvitesApi(this._dio);

  Future<void> accept(String inviteUrlToken) async {
    await _dio.post('/api/v1/invites/accept/$inviteUrlToken');
  }
}
