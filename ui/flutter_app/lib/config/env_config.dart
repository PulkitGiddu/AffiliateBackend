import 'package:flutter/foundation.dart';

/// Environment config. In production, use --dart-define or env files.
class EnvConfig {
  EnvConfig._();

  static const String _baseUrlEnv = String.fromEnvironment(
    'BASE_URL',
    defaultValue: '',
  );

  /// Backend base URL.
  /// When [BASE_URL] is not set: Android uses 10.0.2.2:8081 (emulator → host), others use 127.0.0.1:8081.
  /// Override with: flutter run --dart-define=BASE_URL=http://your-host:8081
  static String get baseUrl {
    if (_baseUrlEnv.isNotEmpty) return _baseUrlEnv;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8081';
    }
    return 'http://127.0.0.1:8081';
  }
}
