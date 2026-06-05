class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.errors,
    this.message,
    this.data,
    this.traceId,
  });

  final bool success;
  final String? message;
  final T? data;
  final List<String> errors;
  final String? traceId;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] == true,
      message: json['message'] as String?,
      data: json['data'] == null ? null : fromJsonT(json['data']),
      errors: (json['errors'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      traceId: json['traceId'] as String?,
    );
  }
}

class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  final List<T> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  factory PagedResult.fromJson(
    Object? json,
    T Function(Object? json) fromJsonT,
  ) {
    final map = json as Map<String, dynamic>;

    return PagedResult<T>(
      items: (map['items'] as List<dynamic>? ?? const [])
          .map((item) => fromJsonT(item))
          .toList(),
      total: (map['total'] as num?)?.toInt() ?? 0,
      page: (map['page'] as num?)?.toInt() ?? 1,
      pageSize: (map['pageSize'] as num?)?.toInt() ?? 20,
      totalPages: (map['totalPages'] as num?)?.toInt() ?? 0,
    );
  }
}
