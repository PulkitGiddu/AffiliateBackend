import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_providers.dart';
import '../../../models/coupon.dart';

final couponListProvider =
    FutureProvider.autoDispose<List<Coupon>>((ref) async {
  return ref.watch(couponRepositoryProvider).getAll();
});
