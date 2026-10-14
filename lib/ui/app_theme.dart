import 'package:flutter/material.dart';

// Palette from ui-ux-pro-max "Healthcare App" (calm cyan + health green),
// darkened where needed so text and buttons keep 4.5:1 contrast.
const _headingFont = 'Lexend';
const _bodyFont = 'Noto Sans';

ThemeData buildAppTheme() => _build(
    const ColorScheme.light(
      primary: Color(0xFF0E7490),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFCFF4FC),
      onPrimaryContainer: Color(0xFF083344),
      secondary: Color(0xFF047857),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD1FAE5),
      onSecondaryContainer: Color(0xFF064E3B),
      tertiary: Color(0xFFB45309),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFFEF3C7),
      onTertiaryContainer: Color(0xFF78350F),
      error: Color(0xFFB91C1C),
      onError: Colors.white,
      errorContainer: Color(0xFFFEE2E2),
      onErrorContainer: Color(0xFF7F1D1D),
      surface: Colors.white,
      onSurface: Color(0xFF0F2F3A),
      onSurfaceVariant: Color(0xFF475569),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Color(0xFFF5FBFC),
      surfaceContainer: Color(0xFFEDF6F8),
      surfaceContainerHigh: Color(0xFFE5F0F3),
      surfaceContainerHighest: Color(0xFFDCEAEE),
      outline: Color(0xFF64748B),
      outlineVariant: Color(0xFFCFE3E9),
    ),
    scaffold: const Color(0xFFF2F8FA));

ThemeData buildDarkAppTheme() => _build(
    const ColorScheme.dark(
      primary: Color(0xFF22D3EE),
      onPrimary: Color(0xFF082F49),
      primaryContainer: Color(0xFF155E75),
      onPrimaryContainer: Color(0xFFCFF4FC),
      secondary: Color(0xFF34D399),
      onSecondary: Color(0xFF052E25),
      secondaryContainer: Color(0xFF065F46),
      onSecondaryContainer: Color(0xFFD1FAE5),
      tertiary: Color(0xFFFBBF24),
      onTertiary: Color(0xFF451A03),
      tertiaryContainer: Color(0xFF78350F),
      onTertiaryContainer: Color(0xFFFEF3C7),
      error: Color(0xFFF87171),
      onError: Color(0xFF450A0A),
      errorContainer: Color(0xFF7F1D1D),
      onErrorContainer: Color(0xFFFEE2E2),
      surface: Color(0xFF0F2229),
      onSurface: Color(0xFFE6F4F7),
      onSurfaceVariant: Color(0xFFA9BCC4),
      surfaceContainerLowest: Color(0xFF0A181D),
      surfaceContainerLow: Color(0xFF13282F),
      surfaceContainer: Color(0xFF172E36),
      surfaceContainerHigh: Color(0xFF1C353E),
      surfaceContainerHighest: Color(0xFF223D47),
      outline: Color(0xFF7C949D),
      outlineVariant: Color(0xFF2A4650),
    ),
    scaffold: const Color(0xFF0A181D));

ThemeData _build(ColorScheme scheme, {required Color scaffold}) {
  final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: scheme.outline));
  final heading = TextStyle(fontFamily: _headingFont, color: scheme.onSurface);
  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
  return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: _bodyFont,
      scaffoldBackgroundColor: scaffold,
      textTheme: TextTheme(
          headlineMedium: heading.copyWith(
              fontSize: 30, fontWeight: FontWeight.w700, height: 1.25),
          headlineSmall: heading.copyWith(
              fontSize: 24, fontWeight: FontWeight.w700, height: 1.3),
          titleLarge: heading.copyWith(
              fontSize: 22, fontWeight: FontWeight.w600, height: 1.3),
          titleMedium: heading.copyWith(
              fontSize: 18, fontWeight: FontWeight.w600, height: 1.35),
          bodyLarge: const TextStyle(fontSize: 16, height: 1.5),
          bodyMedium:
              TextStyle(fontSize: 16, height: 1.5, color: scheme.onSurface),
          bodySmall: TextStyle(
              fontSize: 14, height: 1.45, color: scheme.onSurfaceVariant),
          labelLarge:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      appBarTheme: AppBarTheme(
          backgroundColor: scaffold,
          foregroundColor: scheme.onSurface,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle:
              heading.copyWith(fontSize: 20, fontWeight: FontWeight.w600)),
      cardTheme: CardThemeData(
          color: scheme.surface,
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: scheme.outlineVariant))),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: scheme.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
              borderSide: BorderSide(color: scheme.primary, width: 2)),
          errorMaxLines: 3,
          labelStyle: TextStyle(color: scheme.onSurfaceVariant),
          prefixIconColor: scheme.onSurfaceVariant),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(48, 52),
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: shape)),
      filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
              minimumSize: const Size(48, 52),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: shape)),
      outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
              minimumSize: const Size(48, 52),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              side: BorderSide(color: scheme.outline),
              shape: shape)),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              minimumSize: const Size(48, 48))),
      iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(minimumSize: const Size(48, 48))),
      chipTheme: ChipThemeData(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          side: BorderSide(color: scheme.outlineVariant)),
      navigationBarTheme: NavigationBarThemeData(
          backgroundColor: scheme.surface,
          indicatorColor: scheme.primaryContainer,
          surfaceTintColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) =>
              TextStyle(fontSize: 13, fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400, color: states.contains(WidgetState.selected) ? scheme.onSurface : scheme.onSurfaceVariant))),
      navigationRailTheme: NavigationRailThemeData(backgroundColor: scheme.surface, indicatorColor: scheme.primaryContainer, selectedLabelTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: scheme.onSurface), unselectedLabelTextStyle: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant)),
      dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating));
}
