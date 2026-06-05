class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.statusCode,
    this.errors = const [],
    this.traceId,
  });

  final String message;
  final int? statusCode;
  final List<String> errors;
  final String? traceId;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isLicenseError => statusCode == 402;

  @override
  String toString() {
    final code = statusCode == null ? '' : ' ($statusCode)';
    final trace = traceId == null ? '' : ' traceId=$traceId';
    return 'ApiException$code: $message$trace';
  }
}
