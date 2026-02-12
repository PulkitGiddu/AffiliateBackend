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

    final fullUrl = '${ApiConfig.baseUrl}$path';
    if (kDebugMode) {
      appLog('Auth REGISTER → $fullUrl', tag: 'Auth');
      final p = body['password_hash'] as String?;
      final bodyForLog = Map<String, dynamic>.from(body)..['password_hash'] = '<${p?.length ?? 0} chars>';
      appLog('Auth REGISTER body (snake_case): $bodyForLog', tag: 'Auth');
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

  /// Login via UserSignUpController POST /api/v1/login with UserDTO (email_id, password_hash).
  /// Response is UserDTO (id, email_id, ...); no JWT. We store userId and treat as logged in.
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final path = ApiConfig.userLogin;
    final body = {'email_id': email.trim(), 'password_hash': password};

    final fullUrl = '${ApiConfig.baseUrl}$path';
    if (kDebugMode) {
      appLog('Auth LOGIN → $fullUrl', tag: 'Auth');
      appLog('Auth LOGIN body (UserDTO): email_id=${body['email_id']}, password_hash=<${(body['password_hash'] as String).length} chars>', tag: 'Auth');
    }

    try {
      final res = await _api.dio.post(path, data: body);
      final raw = res.data;
      if (raw is! Map<String, dynamic>) throw ServerException('Invalid response format');
      // Backend POST /api/v1/login returns UserDTO (id, email_id, username, ...) - no token
      final auth = AuthResponse.fromJson(raw);
      if (auth.userId.isEmpty) throw ServerException('No user id in response');
      await _storage.saveToken(auth.token.isNotEmpty ? auth.token : '');
      await _storage.saveUserId(auth.userId);
      return auth;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final msg = (e.response?.data is Map ? (e.response!.data as Map)['message'] : null)?.toString() ?? e.message;
      if (status == 401) throw UnauthorizedException(msg ?? 'Invalid credentials');
      throw ServerException(msg ?? 'Login failed');
    }
  }

  Future<void> logout() async {
    await _storage.clearAuth();
    ApiClient.reset();
  }

  bool get isLoggedIn => (_storage.userId != null && _storage.userId!.isNotEmpty) ||
      (_storage.token != null && _storage.token!.isNotEmpty);
  String? get currentUserId => _storage.userId;
}
