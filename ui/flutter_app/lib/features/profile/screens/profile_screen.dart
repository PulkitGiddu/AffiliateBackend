import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_providers.dart';
import '../../../models/user.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider).valueOrNull;
    final userId = auth?.userId ?? '';
    final userAsync = userId.isNotEmpty ? ref.watch(userProfileProvider(userId)) : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Profile'),
      ),
      body: auth == null
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
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
                  const SizedBox(height: 32),
                  _ThemeSection(ref: ref),
                ],
              ),
            )
          : ListView(
              children: [
                const SizedBox(height: 16),
                _ThemeSection(ref: ref),
                const Divider(),
                userAsync == null
                    ? _ProfileHeader(email: auth.email, userId: auth.userId, displayName: null)
                    : userAsync.when(
                        data: (User? user) => _ProfileHeader(
                          email: user?.email ?? auth.email,
                          userId: auth.userId,
                          displayName: user != null
                              ? [user.firstName, user.lastName].where((e) => e != null && e.isNotEmpty).join(' ').trim()
                              : null,
                          username: user?.username,
                        ),
                        loading: () => _ProfileHeader(email: auth.email, userId: auth.userId, displayName: null),
                        error: (_, __) => _ProfileHeader(email: auth.email, userId: auth.userId, displayName: null),
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.email,
    required this.userId,
    this.displayName,
    this.username,
  });
  final String email;
  final String userId;
  final String? displayName;
  final String? username;

  @override
  Widget build(BuildContext context) {
    final title = displayName?.isNotEmpty == true
        ? displayName!
        : username?.isNotEmpty == true
            ? username!
            : email;
    return ListTile(
      leading: CircleAvatar(
        child: Text(title.isNotEmpty ? title[0].toUpperCase() : '?'),
      ),
      title: Text(email),
      subtitle: Text('User ID: $userId'),
    );
  }
}

class _ThemeSection extends StatelessWidget {
  const _ThemeSection({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('System default'),
                  subtitle: const Text('Follow device setting'),
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  onChanged: (_) => ref.read(themeModeProvider.notifier).setMode(ThemeMode.system),
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text('Light'),
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: (_) => ref.read(themeModeProvider.notifier).setMode(ThemeMode.light),
                ),
                const Divider(height: 1),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark'),
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: (_) => ref.read(themeModeProvider.notifier).setMode(ThemeMode.dark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
