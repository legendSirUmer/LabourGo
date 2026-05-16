import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors (YOUR ORIGINAL)
  static const Color primaryBlue = Color(0xFF3A77FF);
  static const Color deepMidnight = Color(0xFF002F34);
  static const Color successGreen = Color(0xFF28B16D);
  static const Color background = Color(0xFFF2F4F5);
  static const Color surfaceWhite = Color(0xFFFFFFFF);

  // =========================
  // FRIEND COLORS (ADDED ONLY)
  // =========================
  static const Color primary = Color(0xFF4682B4);
  static const Color cyan = Color(0xFF5CE1E6);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  // Opacity colors (YOUR ORIGINAL)
  static final Color borderSubtle = deepMidnight.withOpacity(0.05);
  static final Color textSubtle = deepMidnight.withOpacity(0.60);
  static final Color shadowPrimary = primaryBlue.withOpacity(0.15);

  // Gradient (MERGED)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, cyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: background,

      // =========================
      // COLOR SCHEME (KEEP YOURS)
      // =========================
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        secondary: deepMidnight,
        surface: surfaceWhite,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: deepMidnight,
      ),

      // =========================
      // TEXT THEME (YOUR ORIGINAL)
      // =========================
      textTheme: GoogleFonts.manropeTextTheme().copyWith(
        displayLarge: GoogleFonts.manrope(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: deepMidnight,
          letterSpacing: -0.64,
        ),
        displayMedium: GoogleFonts.manrope(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: deepMidnight,
          letterSpacing: -0.24,
        ),
        displaySmall: GoogleFonts.manrope(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: deepMidnight,
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: deepMidnight,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: deepMidnight,
        ),
        labelLarge: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: deepMidnight,
        ),
        labelSmall: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSubtle,
        ),
      ),

      // =========================
      // FRIEND APPBAR (ADDED)
      // =========================
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // =========================
      // BUTTONS (YOUR ORIGINAL)
      // =========================
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          minimumSize: const Size(double.infinity, 48),
          textStyle: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: deepMidnight,
          side: const BorderSide(color: deepMidnight, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          minimumSize: const Size(double.infinity, 48),
          textStyle: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // =========================
      // INPUT (MERGED + FRIEND HINT STYLE ADDED)
      // =========================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: borderSubtle, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: borderSubtle, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(color: primaryBlue, width: 1),
        ),

        // FRIEND ADDITION
        hintStyle: GoogleFonts.manrope(
          color: textMuted,
          fontSize: 14,
        ),

        labelStyle: GoogleFonts.manrope(
          color: textSubtle,
          fontSize: 14,
        ),
      ),

      // =========================
      // CARD (YOUR ORIGINAL)
      // =========================
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: borderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}

class AppColors {
  static const Color primary = Color(0xFF4682B4);
  static const Color accent = Color(0xFF5CE1E6);
  static const Color white = Colors.white;
  static const Color border = Color(0xFFE5E7EB);
  static const cyan        = Color(0xFF5CE1E6);  // Turquoise
  static const background  = Color(0xFFF0F8FF);  // Alice Blue
  static const card        = Color(0xFFFFFFFF);  // White
  static const textDark    = Color(0xFF1A1A2E);  // Near Black
  static const textMuted   = Color(0xFF6B7280);  // Gray
  static const success     = Color(0xFF4CAF50);  // Green
  static const warning     = Color(0xFFFF9800);  // Orange
  static const error       = Color(0xFFE53935);  // Red

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}