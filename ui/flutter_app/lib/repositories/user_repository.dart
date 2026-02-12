import 'package:dio/dio.dart';
import '../core/network/api_config.dart';
import '../core/network/api_client.dart';
import '../core/errors/exceptions.dart';
import '../core/mock/mock_data_loader.dart';
import '../models/user.dart';

/// Fetches user profile from backend (requires JWT).
class UserRepository {
  UserRepository(this._api);
  final ApiClient _api;

  /// GET /api/v1/{id} — backend returns UserDTO (snake_case).
  Future<User> getById(String id) async {
    if (id.isEmpty) throw ServerException('User ID required');
    try {
      final res = await _api.dio.get(ApiConfig.userById(id));
      final data = res.data;
      if (data is! Map<String, dynamic>) throw ServerException('Invalid response');
      return User.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      if (e.response?.statusCode == 404) throw ServerException('User not found');
      if (useMockWhenOffline) {
        final user = await getMockUser();
        if (user != null) return user;
      }
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message);
    }
  }

  /// PUT /api/v1/{id} — update profile (first_name, last_name, profile_picture_url). Backend expects id in body.
  Future<User> updateUser(String id, {String? firstName, String? lastName, String? profilePictureUrl}) async {
    if (id.isEmpty) throw ServerException('User ID required');
    final body = <String, dynamic>{'id': id};
    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (profilePictureUrl != null) body['profile_picture_url'] = profilePictureUrl;
    try {
      final res = await _api.dio.put(ApiConfig.userById(id), data: body);
      final data = res.data;
      if (data is! Map<String, dynamic>) throw ServerException('Invalid response');
      return User.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      if (e.response?.statusCode == 404) throw ServerException('User not found');
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message);
    }
  }
}
