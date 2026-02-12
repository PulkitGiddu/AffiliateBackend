import 'package:dio/dio.dart';
import '../core/network/api_config.dart';
import '../core/network/api_client.dart';
import '../core/errors/exceptions.dart';
import '../models/budget.dart';

class BudgetRepository {
  BudgetRepository(this._api);
  final ApiClient _api;

  Future<List<Budget>> getByUser(String userId) async {
    try {
      final res = await _api.dio.get(
        ApiConfig.budgets,
        queryParameters: {'userId': userId},
      );
      final data = res.data as Map<String, dynamic>;
      final inner = data['data'] as List<dynamic>? ?? [];
      return inner
          .map((e) => Budget.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message);
    }
  }

  Future<Budget> create({
    required String userId,
    String? productName,
    double? targetPrice,
    double? currentPrice,
    bool alertEnabled = true,
  }) async {
    try {
      final res = await _api.dio.post(
        ApiConfig.budgets,
        data: {
          'userId': userId,
          'productName': productName,
          'targetPrice': targetPrice,
          'currentPrice': currentPrice,
          'alertEnabled': alertEnabled,
        },
      );
      final data = res.data as Map<String, dynamic>;
      final inner = data['data'] as Map<String, dynamic>? ?? data;
      return Budget.fromJson(inner);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message);
    }
  }

  Future<Budget> update(String id, {String? productName, double? targetPrice, double? currentPrice, bool? alertEnabled}) async {
    try {
      final res = await _api.dio.put(
        '${ApiConfig.budgets}/$id',
        data: {
          if (productName != null) 'productName': productName,
          if (targetPrice != null) 'targetPrice': targetPrice,
          if (currentPrice != null) 'currentPrice': currentPrice,
          if (alertEnabled != null) 'alertEnabled': alertEnabled,
        },
      );
      final data = res.data as Map<String, dynamic>;
      final inner = data['data'] as Map<String, dynamic>? ?? data;
      return Budget.fromJson(inner);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _api.dio.delete('${ApiConfig.budgets}/$id');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw UnauthorizedException();
      throw ServerException(e.response?.data?['message']?.toString() ?? e.message);
    }
  }
}
