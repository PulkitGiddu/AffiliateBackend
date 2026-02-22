import 'package:dio/dio.dart';
import '../../utils/logger.dart';

/// Logs request/response in debug mode.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    appLog('REQ ${options.method} ${options.uri}', tag: 'Dio');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    appLog('RES ${response.statusCode} ${response.requestOptions.uri}', tag: 'Dio');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    appLog(
      'ERR ${err.type} ${err.response?.statusCode} ${err.requestOptions.uri} | ${err.message}',
      tag: 'Dio',
    );
    handler.next(err);
  }
}
