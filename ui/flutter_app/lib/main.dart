import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/app_providers.dart';
import 'config/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Request highest display refresh rate (e.g. 90Hz, 120Hz) on Android so the app feels smooth.
  if (Platform.isAndroid) {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (_) {}
  }
  runApp(
    const ProviderScope(
      child: _SplashRoot(),
    ),
  );
}

/// Root that shows a branded splash, then the main app.
class _SplashRoot extends StatefulWidget {
  const _SplashRoot({super.key});

  @override
  State<_SplashRoot> createState() => _SplashRootState();
}

class _SplashRootState extends State<_SplashRoot> with WidgetsBindingObserver {
  bool _showSplash = true;
  bool _splashDark = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadThemeForSplash();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && Platform.isAndroid) {
      FlutterDisplayMode.setHighRefreshRate().ignore();
    }
  }

  Future<void> _loadThemeForSplash() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeStr = prefs.getString(AppConstants.themeModeKey) ?? 'system';
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final bool dark = themeStr == 'dark' ||
          (themeStr == 'system' && brightness == Brightness.dark);
      if (mounted) setState(() => _splashDark = dark);
    } catch (_) {
      // keep _splashDark false (light)
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _showSplash
          ? _SplashScreen(key: const ValueKey('splash'), isDark: _splashDark)
          : const SnatchMartApp(key: ValueKey('app')),
    );
  }
}

/// Splash screen: theme-based background and logo (logo_without_bg) with fade + scale animation.
class _SplashScreen extends StatefulWidget {
  const _SplashScreen({super.key, required this.isDark});

  final bool isDark;

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    const splashAsset = 'lib/asserts/logo_without_bg.png';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        backgroundColor: backgroundColor,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: backgroundColor,
          child: SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacity.value,
                    child: Transform.scale(
                      scale: _scale.value,
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        child: Image.asset(
                          splashAsset,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                          width: 320,
                          height: 160,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown only if prefs load slowly after splash; keeps same look.
class _SplashStyleLoading extends StatelessWidget {
  const _SplashStyleLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2874F0), Color(0xFF1565C0)],
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class SnatchMartApp extends ConsumerWidget {
  const SnatchMartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(sharedPreferencesProvider);

    return prefsAsync.when(
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const _SplashStyleLoading(),
      ),
      error: (e, _) => MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error: $e',
                  style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
      data: (_) {
        final router = ref.watch(goRouterProvider);
        final themeMode = ref.watch(themeModeProvider);
        return MaterialApp.router(
          title: 'SnatchMart',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: router,
        );
      },
    );
  }
}
