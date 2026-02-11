import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/errors/exceptions.dart';

/// Tracks affiliate click on backend before opening merchant link.
class AffiliateClickRepository {
  AffiliateClickRepository(this._api);
  final ApiClient _api;

  Future<void> track({
    String? userId,
    required String productId,
    String? merchantId,
    String? deviceInfo,
    String? ipAddress,
  }) async {
    try {
      await _api.dio.post(
        ApiConstants.affiliateClicks,
        data: {
          if (userId != null) 'userId': userId,
          'productId': productId,
          if (merchantId != null) 'merchantId': merchantId,
          if (deviceInfo != null) 'deviceInfo': deviceInfo,
          if (ipAddress != null) 'ipAddress': ipAddress,
        },
      );
    } on DioException catch (e) {
      // Don't block opening URL on tracking failure
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      rethrow;
    }
  }
}
