import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../core/errors/exceptions.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  NotificationRepository(this._api);
  final ApiClient _api;

  Future<List<NotificationModel>> getByUser(String userId) async {
    try {
      final res = await _api.dio.get(
        ApiConstants.notifications,
        queryParameters: {'userId': userId},
      );
      final data = res.data as Map<String, dynamic>;
      final inner = data['data'] as List<dynamic>? ?? [];
      return inner
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message);
    }
  }

  Future<NotificationModel> markRead(String id) async {
    try {
      final res = await _api.dio.put('${ApiConstants.notifications}/$id/read');
      final data = res.data as Map<String, dynamic>;
      final inner = data['data'] as Map<String, dynamic>? ?? data;
      return NotificationModel.fromJson(inner);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message);
    }
  }
}
