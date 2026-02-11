/// Backend envelope: { success, message, data, timestamp }.
class ApiResponse<T> {
  const ApiResponse({
    this.success = true,
    this.message,
    this.data,
    this.timestamp,
  });

  final bool success;
  final String? message;
  final T? data;
  final String? timestamp;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    final data = json['data'];
    T? parsedData;
    if (data != null && fromJsonT != null) {
      parsedData = fromJsonT(data);
    } else if (data != null && data is T) {
      parsedData = data;
    }
    return ApiResponse<T>(
      success: json['success'] ?? true,
      message: json['message']?.toString(),
      data: parsedData,
      timestamp: json['timestamp']?.toString(),
    );
  }
}

/// Paginated response: { items, page, size, totalElements, totalPages, hasNext }.
class PageResponse<T> {
  const PageResponse({
    this.items = const [],
    this.page = 0,
    this.size = 20,
    this.totalElements = 0,
    this.totalPages = 0,
    this.hasNext = false,
  });

  final List<T> items;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool hasNext;

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    final list = json['items'] as List<dynamic>? ?? [];
    return PageResponse<T>(
      items: list.map((e) => fromJsonT(e)).toList(),
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 20,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      hasNext: json['hasNext'] ?? false,
    );
  }
}
