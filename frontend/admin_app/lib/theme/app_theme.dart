import 'package:flutter/material.dart';

class AppTheme {
  // ─── Brand Colors ─────────────────────────────────────────
  static const Color primaryColor = Color(
    0xFF1A237E,
  ); // Deep Blue (Admin = authority)
  static const Color secondaryColor = Color(0xFF283593);
  static const Color accentColor = Color(0xFF42A5F5); // Light Blue accent
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color warningColor = Color(0xFFFFC107); // Yellow
  static const Color dangerColor = Color(0xFFF44336); // Red
  static const Color bgColor = Color(0xFFF5F6FA); // Light grey bg
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF9E9E9E);

  // ─── Light Theme ──────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: bgColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),

    // Cards
    cardTheme: const CardThemeData(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
    ),

    // Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    useMaterial3: true,
  );
}
