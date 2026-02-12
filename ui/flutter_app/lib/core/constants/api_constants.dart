/// @deprecated Use [ApiConfig] in `core/network/api_config.dart` for base URL and all endpoints.
/// Kept for reference only; new code should use ApiConfig.
class ApiConstants {
  ApiConstants._();

  static const String authRegister = '/api/v1/auth/register';
  static const String authLogin = '/api/v1/auth/login';
  static const String products = '/api/v1/products';
  static const String productPriceHistory = '/api/v1/products';
  static const String categories = '/api/v1/categories';
  static const String coupons = '/api/v1/coupons';
  static const String wishlist = '/api/v1/wishlist';
  static const String budgets = '/api/v1/budgets';
  static const String affiliateClicks = '/api/v1/affiliate-clicks';
  static const String notifications = '/api/v1/notifications';
}
