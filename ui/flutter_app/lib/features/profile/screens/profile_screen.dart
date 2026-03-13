import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/app_providers.dart';
import '../../../models/user.dart';
import '../../auth/providers/auth_provider.dart';

const String kDefaultProfilePhotoUrl =
    'https://avatars.githubusercontent.com/u/101356458?v=4';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider).valueOrNull;
    final userId = auth?.userId ?? '';
    final userAsync = userId.isNotEmpty ? ref.watch(userProfileProvider(userId)) : null;

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: auth == null
          ? _buildLoggedOutContent(context, ref)
          : SafeArea(
              child: CustomScrollView(
                slivers: [
                  // Top bar: email + close (like reference)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              auth.email,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: scheme.onSurface,
                            ),
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Profile picture with colored border + camera overlay
                  SliverToBoxAdapter(
                    child: userAsync == null
                        ? _ProfileAvatar(photoUrl: kDefaultProfilePhotoUrl, onEdit: () => context.push('/profile/edit'))
                        : userAsync.when(
                            data: (User? u) => _ProfileAvatar(
                              photoUrl: u?.profilePictureUrl ?? kDefaultProfilePhotoUrl,
                              onEdit: () => context.push('/profile/edit'),
                            ),
                            loading: () => _ProfileAvatar(photoUrl: kDefaultProfilePhotoUrl, onEdit: () => context.push('/profile/edit')),
                            error: (_, __) => _ProfileAvatar(photoUrl: kDefaultProfilePhotoUrl, onEdit: () => context.push('/profile/edit')),
                          ),
                  ),
                  // Greeting
                  SliverToBoxAdapter(
                    child: userAsync == null
                        ? _Greeting(name: auth.email.split('@').first)
                        : userAsync.when(
                            data: (User? u) {
                              final name = u != null
                                  ? [u.firstName, u.lastName].where((e) => e != null && e.isNotEmpty).join(' ').trim()
                                  : '';
                              return _Greeting(name: name.isEmpty ? auth.email.split('@').first : name);
                            },
                            loading: () => _Greeting(name: auth.email.split('@').first),
                            error: (_, __) => _Greeting(name: auth.email.split('@').first),
                          ),
                  ),
                  // Manage account button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: OutlinedButton(
                        onPressed: () => context.push('/profile/edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: scheme.outline),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        child: const Text('Manage your account'),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  // Section: Dashboard
                  SliverToBoxAdapter(
                    child: _SectionLabel(label: 'Dashboard'),
                  ),
                  SliverToBoxAdapter(
                    child: _SettingsTile(
                      icon: Icons.currency_rupee_rounded,
                      assetPath: 'lib/asserts/iconPack/icons8-paid-50.png',
                      title: 'My Earnings',
                      subtitle: 'Track your commissions',
                      onTap: () {},
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _SettingsTile(
                      icon: Icons.link_rounded,
                      assetPath: 'lib/asserts/iconPack/icons8-sell-50.png',
                      title: 'Make Link',
                      subtitle: 'Create profit links to share',
                      onTap: () => context.push('/profile/make-link'),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _SettingsTile(
                      icon: Icons.show_chart_rounded,
                      assetPath: 'lib/asserts/iconPack/icons8-invoice-50.png',
                      title: 'Reports',
                      subtitle: 'Sales and click analytics',
                      onTap: () {},
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _SettingsTile(
                      icon: Icons.request_quote_rounded,
                      assetPath: 'lib/asserts/iconPack/icons8-online-payment-50.png',
                      title: 'Request Payment',
                      subtitle: 'Withdraw your earnings',
                      onTap: () {},
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  // Section: App & display
                  SliverToBoxAdapter(
                    child: _SectionLabel(label: 'App & display'),
                  ),
                  SliverToBoxAdapter(
                    child: _SettingsTile(
                      icon: Icons.palette_outlined,
                      title: 'Theme',
                      subtitle: _themeSubtitle(ref.watch(themeModeProvider)),
                      onTap: () => _showThemeModal(context, ref),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  // Section: More from this app
                  SliverToBoxAdapter(
                    child: _SectionLabel(label: 'More from this app'),
                  ),
                  SliverToBoxAdapter(
                    child: _SettingsTile(
                      icon: Icons.person_outline_rounded,
                      assetPath: 'lib/asserts/iconPack/icons8-address-50.png',
                      title: 'Edit profile',
                      subtitle: 'Name, profile picture',
                      onTap: () => context.push('/profile/edit'),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _SettingsTile(
                      icon: Icons.favorite_border_rounded,
                      assetPath: 'lib/asserts/iconPack/icons8-unlike-50.png',
                      title: 'Wishlist',
                      subtitle: 'Saved products and deals',
                      onTap: () => context.push('/profile/wishlist'),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _SettingsTile(
                      icon: Icons.savings_outlined,
                      assetPath: 'lib/asserts/iconPack/icons8-budget-50.png',
                      title: 'Budget alerts',
                      subtitle: 'Spending limits and reminders',
                      onTap: () => context.push('/profile/budgets'),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _SettingsTile(
                      icon: Icons.card_giftcard_rounded,
                      assetPath: 'lib/asserts/iconPack/icons8-coupon-50.png',
                      title: 'Coupons',
                      subtitle: 'Discount codes and offers',
                      onTap: () => context.push('/coupons'),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _SettingsTile(
                      icon: Icons.notifications_outlined,
                      assetPath: 'lib/asserts/iconPack/icons8-notification-50.png',
                      title: 'Notifications',
                      subtitle: 'Reminders and recommendations',
                      onTap: () => context.push('/notifications'),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _SettingsTile(
                      icon: Icons.help_outline_rounded,
                      assetPath: 'lib/asserts/iconPack/icons8-online-support-50.png',
                      title: 'Help and feedback',
                      subtitle: 'Chatbot, FAQs and support',
                      onTap: () => context.push('/profile/help'),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  // Sign out
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SettingsTile(
                        icon: Icons.logout_rounded,
                        title: 'Sign out',
                        subtitle: 'Sign out of your account',
                        titleColor: scheme.error,
                        iconColor: scheme.error,
                        onTap: () async {
                          await ref.read(authStateProvider.notifier).logout();
                          ref.invalidate(userProfileProvider);
                          if (context.mounted) context.go('/');
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
    );
  }

  Widget _buildLoggedOutContent(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          ref.watch(mockUserProfileProvider).when(
            data: (User? u) => _ProfileAvatar(
              photoUrl: u?.profilePictureUrl ?? kDefaultProfilePhotoUrl,
              onEdit: () {},
            ),
            loading: () => _ProfileAvatar(photoUrl: kDefaultProfilePhotoUrl, onEdit: () {}),
            error: (_, __) => _ProfileAvatar(photoUrl: kDefaultProfilePhotoUrl, onEdit: () {}),
          ),
          const SizedBox(height: 24),
          Text(
            'Sign in to see your profile',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onSurface),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.push('/login'),
            child: const Text('Sign in'),
          ),
          const SizedBox(height: 32),
          _SectionLabel(label: 'App & display'),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle: _themeSubtitle(ref.watch(themeModeProvider)),
            onTap: () => _showThemeModal(context, ref),
          ),
        ],
      ),
    );
  }
}

String _themeSubtitle(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'Always in light theme';
    case ThemeMode.dark:
      return 'Always in dark theme';
    case ThemeMode.system:
      return 'Same as device theme';
  }
}

/// Theme modal: radio options + Cancel / Save (like reference screenshot).
void _showThemeModal(BuildContext context, WidgetRef ref) {
  final scheme = Theme.of(context).colorScheme;
  ThemeMode initial = ref.read(themeModeProvider);

  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: scheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _ThemeModalContent(
      initialTheme: initial,
      scheme: scheme,
      onSave: (ThemeMode selected) async {
        await ref.read(themeModeProvider.notifier).setMode(selected);
        if (ctx.mounted) Navigator.of(ctx).pop();
      },
    ),
  );
}

class _ThemeModalContent extends StatefulWidget {
  const _ThemeModalContent({
    required this.initialTheme,
    required this.scheme,
    required this.onSave,
  });
  final ThemeMode initialTheme;
  final ColorScheme scheme;
  final ValueChanged<ThemeMode> onSave;

  @override
  State<_ThemeModalContent> createState() => _ThemeModalContentState();
}

class _ThemeModalContentState extends State<_ThemeModalContent> {
  late ThemeMode _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialTheme;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = widget.scheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset : safeBottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Theme',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
            ),
            const SizedBox(height: 16),
            _ThemeOption(
              label: 'Always in light theme',
              icon: Icons.light_mode_rounded,
              isSelected: _selected == ThemeMode.light,
              scheme: scheme,
              onTap: () => setState(() => _selected = ThemeMode.light),
            ),
            const SizedBox(height: 8),
            _ThemeOption(
              label: 'Always in dark theme',
              icon: Icons.dark_mode_rounded,
              isSelected: _selected == ThemeMode.dark,
              scheme: scheme,
              onTap: () => setState(() => _selected = ThemeMode.dark),
            ),
            const SizedBox(height: 8),
            _ThemeOption(
              label: 'Same as device theme',
              icon: Icons.settings_suggest_rounded,
              isSelected: _selected == ThemeMode.system,
              scheme: scheme,
              onTap: () => setState(() => _selected = ThemeMode.system),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: scheme.outline),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => widget.onSave(_selected),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

/// One row: circular icon (or image asset) + title + subtitle (settings style).
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.iconColor,
    this.assetPath,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Color? iconColor;
  /// If set, shows an image asset instead of the icon.
  final String? assetPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).brightness == Brightness.dark
        ? scheme.surfaceContainerHigh
        : scheme.surfaceContainerLow;
    final fg = titleColor ?? scheme.onSurface;
    final iconFg = iconColor ?? scheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: assetPath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset(assetPath!, width: 28, height: 28, fit: BoxFit.contain),
                        )
                      : Icon(icon, color: iconFg, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: fg,
                            ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Large profile avatar with colored border + camera overlay.
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.photoUrl, required this.onEdit});
  final String photoUrl;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const size = 120.0;
    const borderWidth = 4.0;
    const innerSize = size - borderWidth * 2;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Colored border ring (Google-style gradient)
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _GradientRingPainter(
                colors: [
                  scheme.primary,
                  scheme.secondary,
                  const Color(0xFF34A853),
                  const Color(0xFFEA4335),
                ],
                strokeWidth: borderWidth,
              ),
            ),
          ),
          // Inner circle with photo
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.surfaceContainerHigh,
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: photoUrl,
                width: innerSize,
                height: innerSize,
                fit: BoxFit.cover,
                placeholder: (_, __) => Icon(Icons.person, size: 48, color: scheme.onSurfaceVariant),
                errorWidget: (_, __, ___) => Icon(Icons.person, size: 48, color: scheme.onSurfaceVariant),
              ),
            ),
          ),
          // Camera overlay bottom-right
          Positioned(
            right: 4,
            bottom: 4,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: scheme.surface, width: 2),
                ),
                child: Icon(Icons.camera_alt_rounded, size: 18, color: scheme.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientRingPainter extends CustomPainter {
  _GradientRingPainter({required this.colors, required this.strokeWidth});
  final List<Color> colors;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = SweepGradient(
      center: Alignment.center,
      colors: colors,
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2 - strokeWidth / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final display = name.isEmpty ? 'User' : name;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        'Hi, $display!',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.scheme,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool isSelected;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected
            ? scheme.primaryContainer.withOpacity(0.5)
            : scheme.surfaceContainerHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? scheme.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? scheme.onSurface : scheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSelected
                      ? Icon(Icons.check_circle_rounded, key: const ValueKey(true), size: 22, color: scheme.primary)
                      : Icon(Icons.circle_outlined, key: const ValueKey(false), size: 22, color: scheme.onSurfaceVariant.withOpacity(0.4)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
