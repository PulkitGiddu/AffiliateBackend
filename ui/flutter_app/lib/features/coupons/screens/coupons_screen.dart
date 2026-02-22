import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/coupon.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/shimmer_loading.dart';
import '../providers/coupon_provider.dart';

class CouponsScreen extends ConsumerWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsAsync = ref.watch(couponListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text('Coupons'),
      ),
      body: couponsAsync.when(
        data: (list) {
          final active = list.where((c) => c.isActive).toList();
          if (active.isEmpty) {
            return const EmptyState(
              message: 'No active coupons at the moment.',
              icon: Icons.card_giftcard_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(couponListProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: active.length,
              itemBuilder: (_, i) => _CouponTile(coupon: active[i]),
            ),
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          itemBuilder: (_, __) => ShimmerLoading(
            child: Card(
              child: ListTile(
                title: Container(
                  height: 16,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                subtitle: Container(
                  height: 12,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  margin: const EdgeInsets.only(top: 8),
                ),
              ),
            ),
          ),
        ),
        error: (e, _) => EmptyState(
          message: e.toString(),
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}

class _CouponTile extends StatelessWidget {
  const _CouponTile({required this.coupon});

  final Coupon coupon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          coupon.code,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
        ),
        subtitle: Text(
          coupon.description ??
              (coupon.discountType == 'PERCENT'
                  ? '${coupon.discountValue?.toStringAsFixed(0)}% off'
                  : '₹${coupon.discountValue?.toStringAsFixed(0)} off'),
        ),
        trailing: coupon.expiryAt != null
            ? Text(
                'Exp: ${coupon.expiryAt!.toIso8601String().substring(0, 10)}',
                style: Theme.of(context).textTheme.labelSmall,
              )
            : null,
      ),
    );
  }
}
