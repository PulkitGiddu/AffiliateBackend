import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// Persists auth token and userId for JWT and auth state.
class LocalStorageService {
  LocalStorageService(this._prefs);
  final SharedPreferences _prefs;

  String? get token => _prefs.getString(AppConstants.tokenKey);
  String? get userId => _prefs.getString(AppConstants.userIdKey);

  Future<void> saveToken(String token) =>
      _prefs.setString(AppConstants.tokenKey, token);

  Future<void> saveUserId(String id) =>
      _prefs.setString(AppConstants.userIdKey, id);

  Future<void> clearAuth() async {
    await _prefs.remove(AppConstants.tokenKey);
    await _prefs.remove(AppConstants.userIdKey);
  }
}
