import '../network/api_config.dart';

/// Returns a user-friendly message for connection/timeout errors.
String friendlyNetworkError(Object error) {
  final msg = error.toString().toLowerCase();
  if (msg.contains('connection') || msg.contains('timeout') || msg.contains('aborted')) {
    return 'Cannot reach server. Make sure the backend is running at ${ApiConfig.baseUrl}';
  }
  return error.toString();
}
