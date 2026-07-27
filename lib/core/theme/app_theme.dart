import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color gold = Color(0xFFC89733);
  static const Color goldLight = Color(0xFFE0B85C);
  static const Color black = Color(0xFF121212);
  static const Color blackLight = Color(0xFF1A1A1A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray = Color(0xFF9E9E9E);
  static const Color grayDark = Color(0xFF424242);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFFF5F5F5);

  static final ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: gold,
    onPrimary: white,
    primaryContainer: gold.withValues(alpha: 0.15),
    onPrimaryContainer: black,
    secondary: black,
    onSecondary: white,
    secondaryContainer: grayDark,
    onSecondaryContainer: white,
    tertiary: goldLight,
    onTertiary: black,
    tertiaryContainer: gold.withValues(alpha: 0.1),
    onTertiaryContainer: black,
    error: const Color(0xFFB00020),
    onError: white,
    surface: white,
    onSurface: black,
    onSurfaceVariant: gray,
    outline: grayDark,
    outlineVariant: const Color(0xFFE0E0E0),
    surfaceContainerHighest: surfaceLight,
    surfaceContainerHigh: const Color(0xFFEEEEEE),
    surfaceContainer: const Color(0xFFF5F5F5),
    surfaceContainerLow: const Color(0xFFFAFAFA),
    surfaceContainerLowest: white,
  );

  static final ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: gold,
    onPrimary: black,
    primaryContainer: gold.withValues(alpha: 0.2),
    onPrimaryContainer: gold,
    secondary: white,
    onSecondary: black,
    secondaryContainer: grayDark,
    onSecondaryContainer: white,
    tertiary: goldLight,
    onTertiary: black,
    tertiaryContainer: gold.withValues(alpha: 0.15),
    onTertiaryContainer: gold,
    error: const Color(0xFFCF6679),
    onError: black,
    surface: black,
    onSurface: white,
    onSurfaceVariant: gray,
    outline: grayDark,
    outlineVariant: const Color(0xFF333333),
    surfaceContainerHighest: surface,
    surfaceContainerHigh: const Color(0xFF252525),
    surfaceContainer: const Color(0xFF1E1E1E),
    surfaceContainerLow: const Color(0xFF181818),
    surfaceContainerLowest: black,
  );

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightScheme,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: white,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: white,
        foregroundColor: black,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: white,
        indicatorColor: gold.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: gold, fontWeight: FontWeight.w600);
          }
          return const TextStyle(color: gray);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: gold);
          }
          return const IconThemeData(color: gray);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: white,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: black,
          side: const BorderSide(color: grayDark),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: black,
        contentTextStyle: TextStyle(color: white),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkScheme,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: black,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: black,
        foregroundColor: white,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: black,
        indicatorColor: gold.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: gold, fontWeight: FontWeight.w600);
          }
          return const TextStyle(color: gray);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: gold);
          }
          return const IconThemeData(color: gray);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: black,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: black,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: black,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: white,
          side: const BorderSide(color: grayDark),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF333333)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF333333)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF333333)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: gold, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: TextStyle(color: white),
      ),
    );
  }
}
