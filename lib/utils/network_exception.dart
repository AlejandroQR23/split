class APIError {
  final String message;
  final String code;
  final Map<String, dynamic>? details;

  APIError({required this.message, required this.code, this.details});

  factory APIError.fromJson(Map<String, dynamic> json) {
    return APIError(
      message: json['message'] ?? 'Unknown error',
      code: json['code'] ?? 'unknown_error',
      details: json['details'],
    );
  }
}

class NetworkException implements Exception {
  final int statusCode;
  final APIError error;

  NetworkException(this.error, this.statusCode);

  @override
  String toString() {
    return 'NetworkException: ${error.message} (code: ${error.code}, statusCode: $statusCode, details: ${error.details})';
  }
}
