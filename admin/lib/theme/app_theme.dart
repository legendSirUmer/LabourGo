import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors — customer app se match
  static const Color primaryColor = Color(0xFF3A77FF);
  static const Color deepMidnight = Color(0xFF002F34);
  static const Color successColor = Color(0xFF28B16D);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color dangerColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);
  static const Color accentColor = Color(0xFF5CE1E6);
  static const Color background = Color(0xFFF2F4F5);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF002F34);
  static const Color textSecondary = Color(0xFF6B7280);

  // Semantic aliases
  static const Color secondaryColor = deepMidnight;
  static const Color accentColorAlt = accentColor;

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Manrope',
        scaffoldBackgroundColor: background,

        colorScheme: const ColorScheme.light(
          primary: primaryColor,
          secondary: deepMidnight,
          surface: surfaceWhite,
          error: dangerColor,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: deepMidnight,
        ),

        // ───────────────── APP BAR ─────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor: deepMidnight,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Manrope',
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        // ───────────────── NAVIGATION BAR ─────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: surfaceWhite,
          indicatorColor: primaryColor,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: primaryColor,
                fontFamily: 'Manrope',
              );
            }

            return const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: textSecondary,
              fontFamily: 'Manrope',
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: Colors.white,
                size: 22,
              );
            }

            return const IconThemeData(
              color: textSecondary,
              size: 22,
            );
          }),
        ),

        // ───────────────── CARD THEME ─────────────────
        cardTheme: CardThemeData(
          color: surfaceWhite,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
        ),

        // ───────────────── INPUT FIELDS ─────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: primaryColor,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: dangerColor,
            ),
          ),
          labelStyle: const TextStyle(
            color: textSecondary,
            fontSize: 14,
            fontFamily: 'Manrope',
          ),
          hintStyle: const TextStyle(
            color: textSecondary,
            fontSize: 14,
            fontFamily: 'Manrope',
          ),
        ),

        // ───────────────── BUTTONS ─────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Manrope',
            ),
          ),
        ),

        // ───────────────── CHIPS ─────────────────
        chipTheme: ChipThemeData(
          backgroundColor: surfaceWhite,
          selectedColor: primaryColor,
          disabledColor: background,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontFamily: 'Manrope',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide(
            color: Colors.black.withValues(alpha: 0.08),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 2,
          ),
        ),

        // ───────────────── DIVIDER ─────────────────
        dividerTheme: DividerThemeData(
          color: Colors.black.withValues(alpha: 0.06),
          thickness: 1,
        ),

        // ───────────────── LIST TILE ─────────────────
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
        ),
      );
}
