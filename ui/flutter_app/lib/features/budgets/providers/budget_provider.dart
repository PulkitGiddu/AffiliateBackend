import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_providers.dart';
import '../../../models/budget.dart';
import '../../auth/providers/auth_provider.dart';

final budgetListNotifierProvider =
    StateNotifierProvider.autoDispose<BudgetListNotifier, AsyncValue<List<Budget>>>((ref) {
  return BudgetListNotifier(ref);
});

class BudgetListNotifier extends StateNotifier<AsyncValue<List<Budget>>> {
  BudgetListNotifier(this._ref) : super(const AsyncValue.data([])) {
    load();
  }
  final Ref _ref;

  Future<void> load() async {
    final userId = _ref.read(authStateProvider).valueOrNull?.userId;
    if (userId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _ref.read(budgetRepositoryProvider).getByUser(userId);
    });
  }

  Future<void> create({
    String? productName,
    double? targetPrice,
    double? currentPrice,
    bool alertEnabled = true,
  }) async {
    final userId = _ref.read(authStateProvider).valueOrNull?.userId;
    if (userId == null) return;
    await _ref.read(budgetRepositoryProvider).create(
          userId: userId,
          productName: productName,
          targetPrice: targetPrice,
          currentPrice: currentPrice,
          alertEnabled: alertEnabled,
        );
    load();
  }

  Future<void> delete(String id) async {
    await _ref.read(budgetRepositoryProvider).delete(id);
    load();
  }
}
