import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemePreset {
  final String id;
  final String name;
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color primary;
  final Color primaryLight;
  final Color bubbleStart;
  final Color bubbleEnd;
  final Color partnerBubble;

  const ThemePreset({
    required this.id,
    required this.name,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.primary,
    required this.primaryLight,
    required this.bubbleStart,
    required this.bubbleEnd,
    required this.partnerBubble,
  });
}

class AppTheme {
  // Preset Themes
  static const List<ThemePreset> presets = [
    ThemePreset(
      id: "violet",
      name: "أرجواني ملكي (الأساسي) 💜",
      background: Color(0xFF0D0A14),
      surface: Color(0xFF171224),
      surfaceElevated: Color(0xFF221A33),
      primary: Color(0xFF9333EA),
      primaryLight: Color(0xFFC084FC),
      bubbleStart: Color(0xFF7E22CE),
      bubbleEnd: Color(0xFF9333EA),
      partnerBubble: Color(0xFF211832),
    ),
    ThemePreset(
      id: "midnight",
      name: "أسود ليلي فاحم 🖤",
      background: Color(0xFF070709),
      surface: Color(0xFF12141A),
      surfaceElevated: Color(0xFF1D202A),
      primary: Color(0xFF38BDF8),
      primaryLight: Color(0xFF7DD3FC),
      bubbleStart: Color(0xFF0284C7),
      bubbleEnd: Color(0xFF38BDF8),
      partnerBubble: Color(0xFF1B202D),
    ),
    ThemePreset(
      id: "emerald",
      name: "زمرد ليلي هادئ 💚",
      background: Color(0xFF08120D),
      surface: Color(0xFF102118),
      surfaceElevated: Color(0xFF193226),
      primary: Color(0xFF10B981),
      primaryLight: Color(0xFF34D399),
      bubbleStart: Color(0xFF059669),
      bubbleEnd: Color(0xFF10B981),
      partnerBubble: Color(0xFF14271E),
    ),
    ThemePreset(
      id: "rose",
      name: "وردي مخملي رومانسي 🌹",
      background: Color(0xFF140A10),
      surface: Color(0xFF23121D),
      surfaceElevated: Color(0xFF321A2A),
      primary: Color(0xFFF43F5E),
      primaryLight: Color(0xFFFB7185),
      bubbleStart: Color(0xFFE11D48),
      bubbleEnd: Color(0xFFF43F5E),
      partnerBubble: Color(0xFF2B1624),
    ),
    ThemePreset(
      id: "ocean",
      name: "أزرق كوني عميق 🌌",
      background: Color(0xFF080D1A),
      surface: Color(0xFF10182E),
      surfaceElevated: Color(0xFF182444),
      primary: Color(0xFF3B82F6),
      primaryLight: Color(0xFF60A5FA),
      bubbleStart: Color(0xFF2563EB),
      bubbleEnd: Color(0xFF3B82F6),
      partnerBubble: Color(0xFF131D36),
    ),
  ];

  static ThemePreset current = presets[0];

  // Colors shortcut
  static Color get background => current.background;
  static Color get surface => current.surface;
  static Color get surfaceElevated => current.surfaceElevated;
  static Color get primary => current.primary;
  static Color get primaryLight => current.primaryLight;
  static Color get myBubbleStart => current.bubbleStart;
  static Color get myBubbleEnd => current.bubbleEnd;
  static Color get partnerBubble => current.partnerBubble;
  static const Color accentPink = Color(0xFFF43F5E);

  // Text Colors
  static const Color textMain = Color(0xFFF5EEFF);
  static const Color textMuted = Color(0xFFA197B4);
  static const Color textHint = Color(0xFF685D7B);

  static void setTheme(String id) {
    current = presets.firstWhere((p) => p.id == id, orElse: () => presets[0]);
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: primaryLight,
        surface: surface,
      ),
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: textMain,
        displayColor: textMain,
      ),
      appBarTheme: AppBarTheme(
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
