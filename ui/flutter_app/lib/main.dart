import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_providers.dart';
import 'config/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: _SplashRoot(),
    ),
  );
}

/// Root that shows a branded splash for 1.5s, then the main app.
class _SplashRoot extends StatefulWidget {
  const _SplashRoot({super.key});

  @override
  State<_SplashRoot> createState() => _SplashRootState();
}

class _SplashRootState extends State<_SplashRoot> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _showSplash
          ? const _SplashScreen(key: ValueKey('splash'))
          : const SnatchMartApp(key: ValueKey('app')),
    );
  }
}

/// Simple splash screen showing the SnatchMart logo.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: Builder(
        builder: (ctx) => Scaffold(
          backgroundColor: Theme.of(ctx).colorScheme.primary,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Image.asset(
                'lib/asserts/snatchmart.png',
                fit: BoxFit.contain,
              ),
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
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
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
        // Only watch router after SharedPreferences is ready (router depends on auth → apiClient → localStorage → prefs).
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
