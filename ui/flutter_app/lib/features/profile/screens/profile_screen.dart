import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Profile'),
      ),
      body: auth == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Sign in to see your profile',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.push('/login'),
                    child: const Text('Sign in'),
                  ),
                ],
              ),
            )
          : ListView(
              children: [
                const SizedBox(height: 24),
                ListTile(
                  leading: CircleAvatar(
                    child: Text(auth.email.isNotEmpty ? auth.email[0].toUpperCase() : '?'),
                  ),
                  title: Text(auth.email),
                  subtitle: Text('User ID: ${auth.userId}'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const Text('Wishlist'),
                  onTap: () => context.push('/wishlist'),
                ),
                ListTile(
                  leading: const Icon(Icons.savings_outlined),
                  title: const Text('Budget alerts'),
                  onTap: () => context.push('/budgets'),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  onTap: () => context.push('/notifications'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sign out'),
                  onTap: () async {
                    await ref.read(authStateProvider.notifier).logout();
                    if (context.mounted) context.go('/');
                  },
                ),
              ],
            ),
    );
  }
}
