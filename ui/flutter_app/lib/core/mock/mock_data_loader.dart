// =============================================================================
// MOCK DATA FOR OFFLINE / BACKEND-DISCONNECTED DEMO
// =============================================================================
// When backend is not connected, the app uses this JSON to showcase functionality.
//
// TO REMOVE MOCK MODE (one prompt): "Remove mock/offline data: use only real API"
// Then:
// 1. Set [useMockWhenOffline] below to false (or delete this file and all references).
// 2. Delete assets/mock_data.json.
// 3. In repositories: remove the catch blocks that call MockDataLoader (product,
//    category, notification, coupon, user). Keep only the API call and rethrow.
// 4. In notification_provider: remove fallback to MockDataLoader; rely on repo only.
// =============================================================================

import 'dart:convert';

import 'package:flutter/services.dart';
import '../../models/category.dart';
import '../../models/coupon.dart';
import '../../models/notification_model.dart';
import '../../models/product.dart';
import '../../models/user.dart';

/// Set to false to disable mock data entirely (then remove this file + JSON + repo fallbacks).
const bool useMockWhenOffline = true;

const String _assetPath = 'assets/mock_data.json';

Map<String, dynamic>? _cachedJson;

Future<Map<String, dynamic>> _loadJson() async {
  if (_cachedJson != null) return _cachedJson!;
  final str = await rootBundle.loadString(_assetPath);
  final decoded = jsonDecode(str) as Map<String, dynamic>?;
  _cachedJson = decoded ?? {};
  return _cachedJson!;
}

/// Returns mock products for offline demo. Empty if [useMockWhenOffline] is false.
Future<List<Product>> getMockProducts() async {
  if (!useMockWhenOffline) return [];
  try {
    final data = await _loadJson();
    final list = data['products'] as List<dynamic>? ?? [];
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}

/// Returns mock categories for offline demo.
Future<List<Category>> getMockCategories() async {
  if (!useMockWhenOffline) return [];
  try {
    final data = await _loadJson();
    final list = data['categories'] as List<dynamic>? ?? [];
    return list
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}

/// Returns mock notifications for offline demo.
Future<List<NotificationModel>> getMockNotifications() async {
  if (!useMockWhenOffline) return [];
  try {
    final data = await _loadJson();
    final list = data['notifications'] as List<dynamic>? ?? [];
    return list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}

/// Returns mock coupons for offline demo.
Future<List<Coupon>> getMockCoupons() async {
  if (!useMockWhenOffline) return [];
  try {
    final data = await _loadJson();
    final list = data['coupons'] as List<dynamic>? ?? [];
    return list
        .map((e) => Coupon.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
}

/// Returns mock user for profile when backend is unreachable. Null if disabled or missing.
Future<User?> getMockUser() async {
  if (!useMockWhenOffline) return null;
  try {
    final data = await _loadJson();
    final userJson = data['user'] as Map<String, dynamic>?;
    if (userJson == null) return null;
    return User.fromJson(userJson);
  } catch (_) {
    return null;
  }
}
