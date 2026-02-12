import 'package:dio/dio.dart';
import '../core/network/api_config.dart';
import '../core/network/api_client.dart';
import '../core/errors/exceptions.dart';
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
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message);
    }
  }
}
