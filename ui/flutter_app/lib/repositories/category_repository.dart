import 'package:dio/dio.dart';
import '../core/network/api_config.dart';
import '../core/network/api_client.dart';
import '../core/errors/exceptions.dart';
import '../core/mock/mock_data_loader.dart';
import '../models/category.dart';

class CategoryRepository {
  CategoryRepository(this._api);
  final ApiClient _api;

  Future<List<Category>> getAll() async {
    try {
      final res = await _api.dio.get(ApiConfig.categories);
      final raw = res.data;
      List<dynamic> list;
      if (raw is List<dynamic>) {
        list = raw;
      } else if (raw is Map<String, dynamic>) {
        final data = raw['data'];
        list = data is List<dynamic> ? data : <dynamic>[];
      } else {
        list = <dynamic>[];
      }
      return list
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      if (useMockWhenOffline) {
        final list = await getMockCategories();
        if (list.isNotEmpty) return list;
      }
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message);
    }
  }
}
