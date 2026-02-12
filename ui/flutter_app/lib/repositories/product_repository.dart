import 'package:dio/dio.dart';
import '../core/network/api_config.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/errors/exceptions.dart';
import '../models/product.dart';
import '../models/price_history_entry.dart';

class ProductRepository {
  ProductRepository(this._api);
  final ApiClient _api;

  /// Search products with optional filters and pagination.
  Future<({List<Product> items, int page, int totalElements, int totalPages, bool hasNext})> search({
    String? keyword,
    String? categoryId,
    String? merchantId,
    double? minPrice,
    double? maxPrice,
    bool? active,
    int page = 0,
    int size = AppConstants.defaultPageSize,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (keyword != null && keyword.isNotEmpty) query['keyword'] = keyword;
      if (categoryId != null && categoryId.isNotEmpty) query['categoryId'] = categoryId;
      if (merchantId != null) query['merchantId'] = merchantId;
      if (minPrice != null) query['minPrice'] = minPrice;
      if (maxPrice != null) query['maxPrice'] = maxPrice;
      if (active != null) query['active'] = active;

      final res = await _api.dio.get(
        ApiConfig.products,
        queryParameters: query,
      );
      final data = res.data as Map<String, dynamic>;
      final inner = data['data'] as Map<String, dynamic>? ?? data;
      final list = inner['items'] as List<dynamic>? ?? [];
      final items = list
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
      return (
        items: items,
        page: (inner['page'] as num?)?.toInt() ?? 0,
        totalElements: (inner['totalElements'] as num?)?.toInt() ?? 0,
        totalPages: (inner['totalPages'] as num?)?.toInt() ?? 0,
        hasNext: (inner['hasNext'] as bool?) ?? false,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message);
    }
  }

  Future<Product> getById(String id) async {
    try {
      final res = await _api.dio.get('${ApiConfig.products}/$id');
      final data = res.data as Map<String, dynamic>;
      final inner = data['data'] as Map<String, dynamic>? ?? data;
      return Product.fromJson(inner);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message);
    }
  }

  Future<List<PriceHistoryEntry>> getPriceHistory(String productId) async {
    try {
      final res = await _api.dio.get(
        '${ApiConfig.products}/$productId/price-history',
      );
      final data = res.data as Map<String, dynamic>;
      final inner = data['data'] as List<dynamic>? ?? [];
      return inner
          .map((e) => PriceHistoryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message);
    }
  }
}
