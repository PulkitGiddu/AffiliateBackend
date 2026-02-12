import 'package:dio/dio.dart';
import '../core/network/api_config.dart';
import '../core/network/api_client.dart';
import '../core/errors/exceptions.dart';
import '../models/wishlist_item.dart';

class WishlistRepository {
  WishlistRepository(this._api);
  final ApiClient _api;

  Future<List<WishlistItem>> getByUser(String userId) async {
    try {
      final res = await _api.dio.get(
        ApiConfig.wishlist,
        queryParameters: {'userId': userId},
      );
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
          .where((e) => e is Map<String, dynamic>)
          .map((e) => WishlistItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message);
    }
  }

  Future<WishlistItem> add({required String userId, required String productId}) async {
    try {
      final res = await _api.dio.post(
        ApiConfig.wishlist,
        data: {'userId': userId, 'productId': productId},
      );
      final raw = res.data;
      Map<String, dynamic>? map;
      if (raw is Map<String, dynamic>) {
        // ApiResponse envelope: { success, message, data: { ... } }
        final data = raw['data'];
        if (data is Map<String, dynamic>) {
          map = data;
        } else {
          map = raw;
        }
      } else if (raw is List && raw.isNotEmpty && raw.first is Map<String, dynamic>) {
        // Fallback: backend returned a list, take first item
        map = raw.first as Map<String, dynamic>;
      }
      if (map == null) {
        throw ServerException('Invalid wishlist response');
      }
      return WishlistItem.fromJson(map);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message);
    }
  }

  Future<void> remove({required String userId, required String productId}) async {
    try {
      await _api.dio.delete(
        ApiConfig.wishlist,
        queryParameters: {'userId': userId, 'productId': productId},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message);
    }
  }
}
