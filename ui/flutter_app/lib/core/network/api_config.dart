import 'package:flutter/foundation.dart';

/// Single place for backend base URL and all API endpoints.
/// Change [baseUrl] or dart-define BASE_URL to point to a different backend.
class ApiConfig {
  ApiConfig._();

  // --- Base URL ---
  static const String _baseUrlEnv = String.fromEnvironment(
    'BASE_URL',
    defaultValue: '',
  );

  /// Backend base URL. All API calls use this.
  /// When [BASE_URL] is not set: Android uses 10.0.2.2:8081 (emulator only), others use 127.0.0.1:8081.
  /// On a physical Android device, 10.0.2.2 does NOT work — use your computer's LAN IP instead:
  ///   flutter run --dart-define=BASE_URL=http://YOUR_PC_IP:8081
  /// Use your PC's IP (e.g. 192.168.1.3), NOT 192.168.1.255 (that is the broadcast address and will not work).
  /// Same WiFi; find IP: Mac `ipconfig getifaddr en0`, Windows `ipconfig`.
  static bool _warnedEmulatorUrl = false;

  static String get baseUrl {
    if (_baseUrlEnv.isNotEmpty) return _baseUrlEnv;
    if (defaultTargetPlatform == TargetPlatform.android) {
      // 10.0.2.2 = host machine only when using Android *emulator*. On a physical device it will time out.
      if (kDebugMode && !_warnedEmulatorUrl) {
        _warnedEmulatorUrl = true;
        // ignore: avoid_print
        print('ApiConfig: Using http://10.0.2.2:8081 (emulator). On a physical device use: flutter run --dart-define=BASE_URL=http://YOUR_PC_IP:8081');
      }
      return 'http://10.0.2.2:8081';
    }
    return 'http://127.0.0.1:8081';
  }

  // --- Auth (JWT: AuthController) ---
  static const String authLogin = '/api/v1/auth/login';

  // --- User signup (UserSignUpController: UserDTO, same DB) ---
  static const String userRegister = '/api/v1/users';
  static const String userLogin = '/api/v1/login';
  /// GET user by ID (requires JWT). Path: /api/v1/{id}
  static String userById(String id) => '/api/v1/$id';

  // --- Products & categories ---
  static const String products = '/api/v1/products';
  static const String categories = '/api/v1/categories';

  // --- User features ---
  static const String coupons = '/api/v1/coupons';
  static const String wishlist = '/api/v1/wishlist';
  static const String budgets = '/api/v1/budgets';
  static const String notifications = '/api/v1/notifications';
  static const String affiliateClicks = '/api/v1/affiliate-clicks';
}
