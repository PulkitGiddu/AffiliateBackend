import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/errors/exceptions.dart';
import '../models/auth_response.dart';
import '../models/api_response.dart';
import '../services/local_storage_service.dart';

class AuthRepository {
  AuthRepository(this._api, this._storage);
  final ApiClient _api;
  final LocalStorageService _storage;

  Future<AuthResponse> register({
    required String email,
    required String username,
    String? firstName,
    String? lastName,
    required String password,
    String? referredByCode,
    String? profilePictureUrl,
  }) async {
    try {
      final res = await _api.dio.post(
        ApiConstants.authRegister,
        data: {
          'email': email,
          'username': username,
          'firstName': firstName,
          'lastName': lastName,
          'password': password,
          'referredByCode': referredByCode,
          'profilePictureUrl': profilePictureUrl,
        },
      );
      final envelope = ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        (d) => AuthResponse.fromJson(d as Map<String, dynamic>),
      );
      final auth = envelope.data;
      if (auth == null) throw ServerException('Invalid response');
      await _storage.saveToken(auth.token);
      await _storage.saveUserId(auth.userId);
      return auth;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          e.response?.data?['message']?.toString() ?? 'Invalid credentials',
        );
      }
      throw ServerException(
        (e.response?.data as Map?)?['message']?.toString() ?? e.message,
      );
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _api.dio.post(
        ApiConstants.authLogin,
        data: {'email': email, 'password': password},
      );
      final envelope = ApiResponse.fromJson(
        res.data as Map<String, dynamic>,
        (d) => AuthResponse.fromJson(d as Map<String, dynamic>),
      );
      final auth = envelope.data;
      if (auth == null) throw ServerException('Invalid response');
      await _storage.saveToken(auth.token);
      await _storage.saveUserId(auth.userId);
      return auth;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          e.response?.data?['message']?.toString() ?? 'Invalid credentials',
        );
      }
      throw ServerException(
        (e.response?.data as Map?)?['message']?.toString() ?? e.message,
      );
    }
  }

  Future<void> logout() async {
    await _storage.clearAuth();
    ApiClient.reset();
  }

  bool get isLoggedIn => _storage.token != null && _storage.token!.isNotEmpty;
  String? get currentUserId => _storage.userId;
}
