import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import '../utils/logger.dart';
import 'api_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Production Dio client with JWT, logging, and error handling.
/// Timeouts are read from [AppConstants] at creation; do a full restart (not hot reload) to apply changes.
class ApiClient {
  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
    _dio.interceptors.addAll([
      AuthInterceptor(_getToken, _onTokenInvalid),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  static ApiClient? _instance;
  late final Dio _dio;

  String? Function() _getToken = () => null;
  void Function() _onTokenInvalid = () {};

  /// Initialize with token getter and optional logout callback for 401.
  static ApiClient getInstance({
    String? Function()? getToken,
    void Function()? onTokenInvalid,
  }) {
    _instance ??= ApiClient._();
    if (getToken != null) _instance!._getToken = getToken;
    if (onTokenInvalid != null) _instance!._onTokenInvalid = onTokenInvalid;
    return _instance!;
  }

  Dio get dio => _dio;

  /// Reset client (e.g. on logout).
  static void reset() {
    _instance = null;
  }
}

/// Parse backend ApiResponse envelope: { success, message, data, timestamp }.
Map<String, dynamic>? parseData(Map<String, dynamic> json) {
  final data = json['data'];
  if (data == null) return null;
  if (data is Map<String, dynamic>) return data;
  return null;
}

/// Extract list from paginated response: { items, page, size, totalElements, totalPages, hasNext }.
List<T> parsePageItems<T>(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
  final items = json['items'] as List<dynamic>? ?? [];
  return items.map((e) => fromJson(e as Map<String, dynamic>)).toList();
}

/// Throws [ServerException] or [UnauthorizedException] from DioError.
Never throwFromDio(DioException e) {
  appLog('DioError: ${e.type} ${e.response?.statusCode} ${e.message}', tag: 'ApiClient');
  if (e.response?.statusCode == 401) {
    throw UnauthorizedException(e.response?.data?['message']?.toString() ?? 'Unauthorized');
  }
  final msg = e.response?.data is Map
      ? (e.response!.data as Map)['message']?.toString()
      : e.message;
  throw ServerException(msg ?? 'Request failed');
}
