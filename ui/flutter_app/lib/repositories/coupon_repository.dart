import 'package:dio/dio.dart';
import '../core/network/api_config.dart';
import '../core/network/api_client.dart';
import '../core/errors/exceptions.dart';
import '../models/coupon.dart';

class CouponRepository {
  CouponRepository(this._api);
  final ApiClient _api;

  Future<List<Coupon>> getAll() async {
    try {
      final res = await _api.dio.get(ApiConfig.coupons);
      final data = res.data as Map<String, dynamic>;
      final inner = data['data'] as List<dynamic>? ?? [];
      return inner
          .map((e) => Coupon.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message);
    }
  }
}
