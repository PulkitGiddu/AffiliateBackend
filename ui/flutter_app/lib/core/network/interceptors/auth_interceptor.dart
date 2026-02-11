import 'package:dio/dio.dart';

/// Injects JWT into Authorization header. Calls [onTokenInvalid] on 401 response.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._getToken, this._onTokenInvalid);

  final String? Function() _getToken;
  final void Function() _onTokenInvalid;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) _onTokenInvalid();
    handler.next(err);
  }
}
