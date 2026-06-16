import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'The Scalable CFO';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String roleKey = 'user_role';
  static const String themeModeKey = 'theme_mode';

  // REMOVED: static const bool demoMode = true;
  // Backend availability is now determined at runtime by BackendMonitor
}

class AppTheme {
  // === DARK SURFACES ===
  static const Color darkBase = Color(0xFF0A0F1E);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkElevated = Color(0xFF1F2937);
  static const Color darkBorder = Color(0xFF374151);

  // === LIGHT SURFACES ===
  static const Color lightBase = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // === NAVY (brand) ===
  static const Color navyDeep = Color(0xFF0B1F3A);
  static const Color navyMid = Color(0xFF1A3A5C);
  static const Color navyLight = Color(0xFF234E7A);

  // === SEMANTIC ===
  static const Color emerald = Color(0xFF10B981);
  static const Color amber = Color(0xFFF59E0B);
  static const Color coral = Color(0xFFEF4444);
  static const Color gold = Color(0xFFD4AF37);

  // === TEXT ===
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnDark = Color(0xFFF8FAFC);
  static const Color textOnDarkMuted = Color(0xFF94A3B8);

  // Backward-compatible aliases
  static const Color primary = navyDeep;
  static const Color primaryDark = navyDeep;
  static const Color primaryLight = navyLight;
  static const Color accent = Color(0xFF00BFA5);
  static const Color success = emerald;
  static const Color warning = amber;
  static const Color error = coral;
  static const Color info = Color(0xFF2196F3);
  static const Color backgroundLight = lightBase;
  static const Color surfaceLight = lightSurface;
  static const Color textHint = textMuted;
  static const Color border = lightBorder;
  static const Color divider = lightBorder;

  // Backward-compatible gradient aliases
  static const LinearGradient primaryGradient = navyGradient;
  static const Color accentGold = gold;

  // Theme-aware helpers — call on BuildContext to get dark/light variant
  static Color surfaceColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkSurface
          : lightSurface;
  static Color baseColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBase : lightBase;
  static Color elevatedColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkElevated
          : lightElevated;
  static Color borderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? darkBorder
          : lightBorder;
  static Color onSurfaceText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textOnDark
          : textPrimary;
  static Color onSurfaceTextSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textOnDarkMuted
          : textSecondary;
  static Color onSurfaceTextMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textOnDarkMuted
          : textMuted;
  static Color iconOnSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? gold : navyDeep;

  // === GRADIENTS ===
  static const LinearGradient navyGradient = LinearGradient(
    colors: [Color(0xFF0B1F3A), Color(0xFF1A3A5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient madiBriefingGradient = LinearGradient(
    colors: [Color(0xFF0B1F3A), Color(0xFF0D2B4E), Color(0xFF1A3A5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // === TYPOGRAPHY ===
  static const TextStyle labelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: Color(0xFF64748B),
  );

  static const TextStyle metricLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    color: Color(0xFF0F172A),
  );

  static const TextStyle metricMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: Color(0xFF0F172A),
  );

  static const TextStyle madiBriefingText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.7,
    color: Color(0xFFF8FAFC),
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: Color(0xFF64748B),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: navyDeep,
        secondary: gold,
        surface: lightSurface,
        error: coral,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: lightBase,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: lightSurface,
        foregroundColor: textPrimary,
        scrolledUnderElevation: 1,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder, width: 0.5),
        ),
        margin: const EdgeInsets.only(bottom: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navyDeep,
          foregroundColor: Colors.white,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: coral),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: navyDeep,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: gold,
        secondary: navyMid,
        surface: darkSurface,
        error: coral,
        onPrimary: darkBase,
        onSecondary: Colors.white,
        onSurface: textOnDark,
      ),
      scaffoldBackgroundColor: darkBase,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: navyDeep,
        foregroundColor: textOnDark,
        scrolledUnderElevation: 2,
        titleTextStyle: TextStyle(
          color: textOnDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkElevated,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 0.5),
        ),
        margin: const EdgeInsets.only(bottom: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navyMid,
          foregroundColor: textOnDark,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: gold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: coral),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(color: textOnDarkMuted),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: gold,
        unselectedItemColor: textOnDarkMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
