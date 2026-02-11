import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/errors/exceptions.dart';
import '../models/wishlist_item.dart';

class WishlistRepository {
  WishlistRepository(this._api);
  final ApiClient _api;

  Future<List<WishlistItem>> getByUser(String userId) async {
    try {
      final res = await _api.dio.get(
        ApiConstants.wishlist,
        queryParameters: {'userId': userId},
      );
      final data = res.data as Map<String, dynamic>;
      final inner = data['data'] as List<dynamic>? ?? [];
      return inner
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
        ApiConstants.wishlist,
        data: {'userId': userId, 'productId': productId},
      );
      final data = res.data as Map<String, dynamic>;
      final inner = data['data'] as Map<String, dynamic>? ?? data;
      return WishlistItem.fromJson(inner);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message);
    }
  }

  Future<void> remove({required String userId, required String productId}) async {
    try {
      await _api.dio.delete(
        ApiConstants.wishlist,
        queryParameters: {'userId': userId, 'productId': productId},
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message);
    }
  }
}
