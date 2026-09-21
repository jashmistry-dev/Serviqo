import 'package:flutter/material.dart';

/// Serviqo application theme.
/// Colors and typography will be refined in Step 4 (UI implementation).
class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFF4F46E5);      // Indigo
  static const Color secondaryColor = Color(0xFF7C3AED);    // Purple
  static const Color errorColor = Color(0xFFEF4444);        // Red
  static const Color successColor = Color(0xFF10B981);      // Emerald
  static const Color backgroundDark = Color(0xFF1A1A2E);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      );
}
