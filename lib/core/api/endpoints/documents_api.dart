import 'package:dio/dio.dart';

class DocumentsApi {
  final Dio _dio;

  DocumentsApi(this._dio);

  /// Generate lease document. Returns documentId and downloadUrl.
  Future<DocumentGenerateResponse> generateForLease(String leaseId) async {
    final res = await _dio.post('/api/v1/documents/leases/$leaseId/generate');
    final m = res.data as Map<String, dynamic>;
    return DocumentGenerateResponse(
      documentId: m['documentId']?.toString() ?? '',
      downloadUrl: m['downloadUrl'] as String? ?? '',
    );
  }

  /// Accept (e-sign) document with typed name.
  Future<void> accept(String documentId, {required String typedName}) async {
    await _dio.post(
      '/api/v1/documents/$documentId/accept',
      data: {'typedName': typedName, 'acceptedAt': DateTime.now().toIso8601String()},
    );
  }

  /// Full download URL (baseUrl + path).
  String downloadUrl(String path) {
    final base = _dio.options.baseUrl;
    return path.startsWith('http') ? path : '$base$path';
  }
}

class DocumentGenerateResponse {
  final String documentId;
  final String downloadUrl;
  DocumentGenerateResponse({required this.documentId, required this.downloadUrl});
}
