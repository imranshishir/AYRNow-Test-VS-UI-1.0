/// Typed API exceptions mapped from backend error envelope.
class ApiException implements Exception {
  final String errorCode;
  final String message;
  final Map<String, String>? fields;
  final int? statusCode;

  const ApiException({
    required this.errorCode,
    required this.message,
    this.fields,
    this.statusCode,
  });

  bool get isUnauthorized => statusCode == 401 || errorCode == 'unauthorized';
  bool get isForbidden => statusCode == 403 || errorCode == 'forbidden';
  bool get isNotFound => statusCode == 404 || errorCode == 'not_found';
  bool get isConflict => statusCode == 409 || errorCode == 'conflict';
  bool get isValidation => statusCode == 400 && errorCode == 'validation_error';

  @override
  String toString() => 'ApiException($errorCode): $message';
}
