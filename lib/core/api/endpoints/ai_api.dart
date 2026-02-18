import 'package:dio/dio.dart';

class AiLeaseDraftResponse {
  final String draftText;
  final List<Map<String, dynamic>> sections;

  AiLeaseDraftResponse({required this.draftText, required this.sections});

  factory AiLeaseDraftResponse.fromJson(Map<String, dynamic> json) {
    final sections = (json['sections'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];
    return AiLeaseDraftResponse(
      draftText: json['draftText'] as String? ?? '',
      sections: sections,
    );
  }
}

class AiApi {
  final Dio _dio;

  AiApi(this._dio);

  Future<AiLeaseDraftResponse> generateLeaseDraft({
    required String propertyId,
    required String unitId,
    required String leaseId,
  }) async {
    final res = await _dio.post(
      '/api/v1/ai/lease-draft',
      data: {
        'propertyId': propertyId,
        'unitId': unitId,
        'leaseId': leaseId,
      },
    );
    return AiLeaseDraftResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
