import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/network/api_config.dart';
import '../core/network/api_client.dart';
import '../core/errors/exceptions.dart';
import '../core/utils/logger.dart';
import '../models/auth_response.dart';
import '../services/local_storage_service.dart';

class AuthRepository {
  AuthRepository(this._api, this._storage);
  final ApiClient _api;
  final LocalStorageService _storage;

  /// Register via UserSignUpController (POST /api/v1/users) with UserDTO (snake_case).
  /// On success, auto-login via AuthController to get JWT.
  Future<AuthResponse> register({
    required String email,
    required String username,
    String? firstName,
    String? lastName,
    required String password,
    String? referredByCode,
    String? profilePictureUrl,
  }) async {
    final path = ApiConfig.userRegister;
    final body = <String, dynamic>{
      'email_id': email.trim(),
      'username': username.trim(),
      'password_hash': password,
    };
    if (firstName != null && firstName.isNotEmpty) body['first_name'] = firstName.trim();
    if (lastName != null && lastName.isNotEmpty) body['last_name'] = lastName.trim();
    if (referredByCode != null && referredByCode.isNotEmpty) body['referred_by_code'] = referredByCode.trim();
    if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) body['profile_picture_url'] = profilePictureUrl;

    if (kDebugMode) {
      appLog('Auth REGISTER (UserSignUp) → ${ApiConfig.baseUrl}$path', tag: 'Auth');
    }

    try {
      final res = await _api.dio.post(path, data: body);
      if (res.statusCode != 201) throw ServerException('Registration failed');
      // User created; get JWT by logging in (AuthController)
      return login(email: email.trim(), password: password);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final msg = (e.response?.data is Map ? (e.response!.data as Map)['message'] : null)?.toString() ?? e.message;
      if (status == 409) throw ServerException(msg ?? 'Email or username already registered.');
      if (status == 400 || status == 401) throw ServerException(msg ?? 'Invalid input.');
      throw ServerException(msg ?? 'Registration failed');
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final path = ApiConfig.authLogin;
    final body = {'email': email.trim(), 'password': password};

    if (kDebugMode) {
      appLog('Auth LOGIN → ${ApiConfig.baseUrl}$path', tag: 'Auth');
    }

    try {
      final res = await _api.dio.post(path, data: body);
      final raw = res.data;
      if (raw is! Map<String, dynamic>) throw ServerException('Invalid response format');
      // Backend returns { success, message, data: { userId, email, token }, timestamp }
      Map<String, dynamic>? dataMap = raw['data'] as Map<String, dynamic>?;
      if (dataMap == null && _looksLikeAuth(raw)) dataMap = raw;
      if (dataMap == null) throw ServerException('Invalid response');
      final auth = AuthResponse.fromJson(dataMap);
      if (auth.token.isEmpty) throw ServerException('No token in response');
      await _storage.saveToken(auth.token);
      await _storage.saveUserId(auth.userId);
      return auth;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final msg = (e.response?.data is Map ? (e.response!.data as Map)['message'] : null)?.toString() ?? e.message;
      if (status == 401) throw UnauthorizedException(msg ?? 'Invalid credentials');
      throw ServerException(msg ?? 'Login failed');
    }
  }

  static bool _looksLikeAuth(Map<String, dynamic> json) =>
      json.containsKey('token') && (json.containsKey('userId') || json.containsKey('user_id'));

  Future<void> logout() async {
    await _storage.clearAuth();
    ApiClient.reset();
  }

  bool get isLoggedIn => _storage.token != null && _storage.token!.isNotEmpty;
  String? get currentUserId => _storage.userId;
}
