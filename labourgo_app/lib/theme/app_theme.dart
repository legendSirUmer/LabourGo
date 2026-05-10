import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF3A77FF);
  static const Color deepMidnight = Color(0xFF002F34);
  static const Color successGreen = Color(0xFF28B16D);
  static const Color background = Color(0xFFF2F4F5);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  
  // Opacity colors
  static final Color borderSubtle = deepMidnight.withOpacity(0.05);
  static final Color textSubtle = deepMidnight.withOpacity(0.60);
  static final Color shadowPrimary = primaryBlue.withOpacity(0.15);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.light(
        primary: primaryBlue,
        secondary: deepMidnight,
        surface: surfaceWhite,
        background: background,
        error: Colors.redAccent,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: deepMidnight,
        onBackground: deepMidnight,
      ),
      textTheme: GoogleFonts.manropeTextTheme().copyWith(
        displayLarge: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w800, color: deepMidnight, letterSpacing: -0.64),
        displayMedium: GoogleFonts.manrope(fontSize: 24, fontWeight: FontWeight.w700, color: deepMidnight, letterSpacing: -0.24),
        displaySmall: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: deepMidnight),
        bodyLarge: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w400, color: deepMidnight),
        bodyMedium: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w400, color: deepMidnight),
        labelLarge: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: deepMidnight),
        labelSmall: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w500, color: textSubtle),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0, // Flat until pressed, handle shadow manually if needed
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          minimumSize: const Size(double.infinity, 48), // Full width
          textStyle: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600),
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
          textStyle: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: borderSubtle, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: borderSubtle, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: primaryBlue, width: 1),
        ),
        labelStyle: GoogleFonts.manrope(color: textSubtle, fontSize: 14),
      ),
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
