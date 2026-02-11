import 'package:dio/dio.dart';

/// Placeholder for global error handling (e.g. show snackbar on 5xx).
/// Repositories catch DioException and map to Failure/Exception.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
