import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/budget.dart';
import '../../../widgets/empty_state.dart';
import '../providers/budget_provider.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Budget alerts'),
      ),
      body: budgetAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              message:
                  'No budget alerts. Set a target price from a product detail page.',
              icon: Icons.savings_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(budgetListNotifierProvider.notifier).load(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (_, i) => _BudgetTile(
                budget: list[i],
                onDelete: () => ref
                    .read(budgetListNotifierProvider.notifier)
                    .delete(list[i].id),
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(
          message: e.toString(),
          icon: Icons.error_outline,
        ),
      ),
    );
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({required this.budget, required this.onDelete});

  final Budget budget;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          budget.productName ?? 'Budget alert',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(
          'Target: ₹${budget.targetPrice?.toStringAsFixed(0) ?? "-"} • '
          'Current: ₹${budget.currentPrice?.toStringAsFixed(0) ?? "-"}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
