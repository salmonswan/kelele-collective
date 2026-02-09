import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KeleleColors {
  static const pink = Color(0xFFFF1A66);
  static const pinkDark = Color(0xFFC40041);
  static const pinkLight = Color(0xFFFF4D8A);
  static const pinkGlow = Color(0xFFFFF0F5);
  static const yellow = Color(0xFFF4FF7A);
  static const dark = Color(0xFF0C0C20);
  static const darkSoft = Color(0xFF1A1A35);
  static const white = Color(0xFFFFFFFF);
  static const grayLight = Color(0xFFF6F6F9);
  static const grayBorder = Color(0xFFE8E8EE);
  static const grayMid = Color(0xFF888899);
  static const green = Color(0xFF22C55E);
  static const greenGlow = Color(0xFFECFDF5);
  static const orange = Color(0xFFF59E0B);
  static const orangeGlow = Color(0xFFFFFBEB);
  static const red = Color(0xFFEF4444);
  static const redGlow = Color(0xFFFEF2F2);
  static const purple = Color(0xFF6366F1);
}

class KeleleTheme {
  static TextStyle get headlineFont =>
      GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700);

  static TextStyle get bodyFont =>
      GoogleFonts.dmSans();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: KeleleColors.white,
      colorScheme: ColorScheme.light(
        primary: KeleleColors.pink,
        onPrimary: KeleleColors.white,
        surface: KeleleColors.white,
        onSurface: KeleleColors.dark,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
          color: KeleleColors.dark,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
          color: KeleleColors.dark,
        ),
        headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: KeleleColors.dark,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: KeleleColors.dark,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: KeleleColors.dark,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: KeleleColors.dark,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16,
          color: KeleleColors.dark,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          color: KeleleColors.dark,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 12,
          color: KeleleColors.grayMid,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: KeleleColors.dark,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: KeleleColors.grayMid,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: KeleleColors.white,
        foregroundColor: KeleleColors.dark,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: KeleleColors.dark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KeleleColors.pink,
          foregroundColor: KeleleColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KeleleColors.dark,
          side: const BorderSide(color: KeleleColors.grayBorder),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KeleleColors.grayLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: KeleleColors.grayBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: KeleleColors.grayBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: KeleleColors.pink, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: KeleleColors.grayMid,
        ),
        labelStyle: GoogleFonts.dmSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: KeleleColors.grayMid,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: KeleleColors.grayLight,
        labelStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        side: BorderSide.none,
      ),
      dividerColor: KeleleColors.grayBorder,
    );
  }
}
