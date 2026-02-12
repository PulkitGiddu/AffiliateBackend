/// App-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'SnatchMart';
  static const int defaultPageSize = 20;
  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String refreshTokenKey = 'refresh_token';
  static const String skippedLoginKey = 'skipped_login';
  static const String themeModeKey = 'theme_mode'; // 'system' | 'light' | 'dark'
}
