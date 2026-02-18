import 'package:ayrnow/core/api/api_errors.dart';

/// Backend error envelope: error, message, fields
class ErrorResponse {
  final String error;
  final String message;
  final Map<String, String>? fields;

  const ErrorResponse({
    required this.error,
    required this.message,
    this.fields,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    final fieldsRaw = json['fields'];
    Map<String, String>? fieldsMap;
    if (fieldsRaw is Map) {
      fieldsMap = {};
      for (final e in fieldsRaw.entries) {
        if (e.value != null) {
          fieldsMap[e.key.toString()] = e.value.toString();
        }
      }
      if (fieldsMap.isEmpty) fieldsMap = null;
    }
    return ErrorResponse(
      error: json['error'] as String? ?? 'unknown',
      message: json['message'] as String? ?? 'An error occurred',
      fields: fieldsMap,
    );
  }

  ApiException toException([int? statusCode]) {
    return ApiException(
      errorCode: error,
      message: message,
      fields: fields,
      statusCode: statusCode,
    );
  }
}
