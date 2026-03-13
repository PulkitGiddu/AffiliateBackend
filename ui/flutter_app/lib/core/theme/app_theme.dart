import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  static const Color _blue = Color(0xFF2874F0);
  static const Color _yellow = Color(0xFFFFE500);
  static const Color _blueDark = Color(0xFF5C9AFF);
  static const Color _yellowDark = Color(0xFFFFD740);

  // ---------- LIGHT ----------

  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: _blue,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFD6E3FF),
      onPrimaryContainer: Color(0xFF001B3F),
      secondary: _yellow,
      onSecondary: Color(0xFF1A1A00),
      secondaryContainer: Color(0xFFFFF4B8),
      onSecondaryContainer: Color(0xFF3D3500),
      tertiary: Color(0xFF1565C0),
      onTertiary: Colors.white,
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      surface: Color(0xFFF5F6FA),
      onSurface: Color(0xFF1A1C1E),
      onSurfaceVariant: Color(0xFF43474E),
      outline: Color(0xFF73777F),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Color(0xFFF0F1F5),
      surfaceContainer: Color(0xFFEAECF0),
      surfaceContainerHigh: Color(0xFFE4E6EB),
      surfaceContainerHighest: Color(0xFFDFE1E6),
      inverseSurface: Color(0xFF2F3033),
      onInverseSurface: Color(0xFFF1F0F4),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: scheme.surfaceContainerLow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 64,
        indicatorColor: _yellow.withOpacity(0.95),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _yellow,
        foregroundColor: Color(0xFF1A1A00),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withOpacity(0.3),
        thickness: 0.5,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ---------- DARK (Paytm-style: warm charcoal, no pure black) ----------

  static ThemeData get dark {
    const Color bg = Color(0xFF141218);
    const Color surfaceDim = Color(0xFF1B1B1F);
    const Color surfaceBase = Color(0xFF1E1E23);
    const Color containerLow = Color(0xFF232328);
    const Color container = Color(0xFF28282E);
    const Color containerHigh = Color(0xFF2E2E35);
    const Color containerHighest = Color(0xFF36363D);
    const Color onSurface = Color(0xFFE6E1E5);
    const Color onSurfaceVar = Color(0xFFC4C0C8);

    const scheme = ColorScheme.dark(
      primary: _blueDark,
      onPrimary: Color(0xFF002F6C),
      primaryContainer: Color(0xFF1A4A8A),
      onPrimaryContainer: Color(0xFFD6E3FF),
      secondary: _yellowDark,
      onSecondary: Color(0xFF3D3500),
      secondaryContainer: Color(0xFF524600),
      onSecondaryContainer: Color(0xFFFFF4B8),
      tertiary: Color(0xFF82B1FF),
      onTertiary: Color(0xFF002640),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      surface: surfaceBase,
      surfaceDim: surfaceDim,
      surfaceContainerLowest: bg,
      surfaceContainerLow: containerLow,
      surfaceContainer: container,
      surfaceContainerHigh: containerHigh,
      surfaceContainerHighest: containerHighest,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVar,
      outline: Color(0xFF6C6C75),
      outlineVariant: Color(0xFF46464F),
      inverseSurface: Color(0xFFE6E1E5),
      onInverseSurface: Color(0xFF313033),
      shadow: Colors.black,
      scrim: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: containerLow,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: onSurface),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: containerHigh,
        surfaceTintColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: containerHigh,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 64,
        indicatorColor: _yellowDark.withOpacity(0.2),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _yellowDark,
        foregroundColor: Color(0xFF3D3500),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withOpacity(0.3),
        thickness: 0.5,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: containerHigh,
        modalBackgroundColor: containerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: containerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
