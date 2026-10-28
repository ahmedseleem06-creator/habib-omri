import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBackground = Color(0xFF070A13);
  static const Color cardColor = Color(0xFF0F1424);
  static const Color borderColor = Color(0xFF1F2942);

  // Brand Accents
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color electricIndigo = Color(0xFF6366F1);
  static const Color cyberCyan = Color(0xFF06B6D4);
  static const Color neonPink = Color(0xFFEC4899);
  static const Color neonEmerald = Color(0xFF10B981);
  static const Color neonAmber = Color(0xFFF59E0B);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: electricIndigo,
      cardColor: cardColor,
      colorScheme: const ColorScheme.dark(
        primary: electricIndigo,
        secondary: primaryPurple,
        surface: cardColor,
        background: darkBackground,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0B0F1C),
        selectedItemColor: cyberCyan,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
    );
  }
}
