import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Midnight Dark & Violet Palette (Telegram Sleek Style)
  static const Color background = Color(0xFF0D0A14);
  static const Color surface = Color(0xFF171224);
  static const Color surfaceElevated = Color(0xFF221A33);
  static const Color cardColor = Color(0xFF2A1F3F);
  
  static const Color primary = Color(0xFF9333EA);       // Vivid Purple
  static const Color primaryLight = Color(0xFFC084FC);  // Soft Neon Lavender
  static const Color primaryDark = Color(0xFF6B21A8);
  static const Color accentPink = Color(0xFFF43F5E);    // Romantic Rose
  
  // Message Bubbles
  static const Color myBubbleStart = Color(0xFF7E22CE);
  static const Color myBubbleEnd = Color(0xFF9333EA);
  static const Color partnerBubble = Color(0xFF211832);

  // Text Colors
  static const Color textMain = Color(0xFFF5EEFF);
  static const Color textMuted = Color(0xFFA197B4);
  static const Color textHint = Color(0xFF685D7B);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: primaryLight,
        surface: surface,
        background: background,
      ),
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: textMain,
        displayColor: textMain,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: primaryLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
    );
  }
}
