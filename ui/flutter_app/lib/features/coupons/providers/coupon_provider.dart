import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_providers.dart';
import '../../../models/coupon.dart';

final couponListProvider =
    FutureProvider.autoDispose<List<Coupon>>((ref) async {
  try {
    final list = await ref.watch(couponRepositoryProvider).getAll();
    if (list.isNotEmpty) return list;
  } catch (_) {}
  return _defaultCoupons;
});

final List<Coupon> _defaultCoupons = [
  Coupon(
    id: 'c1',
    code: 'SNATCH500',
    description: '₹500 off on orders above ₹2,999',
    discountType: 'FLAT',
    discountValue: 500,
    expiryAt: DateTime.now().add(const Duration(days: 7)),
    isActive: true,
  ),
  Coupon(
    id: 'c2',
    code: 'FIRST20',
    description: '20% off on your first purchase (up to ₹300)',
    discountType: 'PERCENT',
    discountValue: 20,
    expiryAt: DateTime.now().add(const Duration(days: 30)),
    isActive: true,
  ),
  Coupon(
    id: 'c3',
    code: 'FLASH50',
    description: 'Flat 50% off on electronics (max ₹1,000)',
    discountType: 'PERCENT',
    discountValue: 50,
    expiryAt: DateTime.now().add(const Duration(days: 2)),
    isActive: true,
  ),
  Coupon(
    id: 'c4',
    code: 'FASHION25',
    description: '25% off on all fashion products',
    discountType: 'PERCENT',
    discountValue: 25,
    expiryAt: DateTime.now().add(const Duration(days: 14)),
    isActive: true,
  ),
  Coupon(
    id: 'c5',
    code: 'WEEKEND100',
    description: '₹100 off on weekend orders (no minimum)',
    discountType: 'FLAT',
    discountValue: 100,
    expiryAt: DateTime.now().add(const Duration(days: 5)),
    isActive: true,
  ),
  Coupon(
    id: 'c6',
    code: 'MEGA1000',
    description: '₹1,000 off on orders above ₹5,999',
    discountType: 'FLAT',
    discountValue: 1000,
    expiryAt: DateTime.now().add(const Duration(days: 10)),
    isActive: true,
  ),
  Coupon(
    id: 'c7',
    code: 'BEAUTY30',
    description: '30% off on beauty and personal care',
    discountType: 'PERCENT',
    discountValue: 30,
    expiryAt: DateTime.now().add(const Duration(days: 21)),
    isActive: true,
  ),
  Coupon(
    id: 'c8',
    code: 'FREEDEL',
    description: 'Free delivery on all orders today',
    discountType: 'FLAT',
    discountValue: 0,
    expiryAt: DateTime.now().add(const Duration(days: 1)),
    isActive: true,
  ),
];
