/// Base exception for API/local errors.
class AppException implements Exception {
  AppException([this.message]);
  final String? message;
  @override
  String toString() => message ?? 'AppException';
}

class ServerException extends AppException {
  ServerException([super.message]);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([super.message]);
}

class NetworkException extends AppException {
  NetworkException([super.message]);
}

class CacheException extends AppException {
  CacheException([super.message]);
}
