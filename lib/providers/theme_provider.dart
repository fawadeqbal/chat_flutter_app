import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // ─── Snapchat-Style Color Tokens ───

  // Primary & Secondary
  // Primary & Secondary
  Color get primary => _isDarkMode ? const Color(0xFF00AF91) : const Color(0xFF00897B);
  Color get secondary => primary;

  // Backgrounds
  Color get bgPrimary => _isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  Color get bgSurface => _isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  Color get bgSecondary => _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF0F0F2);
  Color get bgInput => _isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFEBEBEB);
  Color get bgCard => _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

  // Text
  Color get textPrimary => _isDarkMode ? Colors.white : const Color(0xFF000000);
  Color get textSecondary => const Color(0xFF8E8E93);
  Color get textMuted => _isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF666666);
  Color get textDim => _isDarkMode ? const Color(0xFFD1D1D6) : const Color(0xFF3C3C3E);
  Color get textOnPrimary => Colors.white;

  // Accent (legacy compat — maps to primary)
  Color get accent => primary;
  Color get accentLight => _isDarkMode ? primary.withOpacity(0.15) : const Color(0xFFE0FFF7);

  // Avatar Colors — Snapchat-style colorful circle backgrounds
  static const List<Color> avatarColors = [
    Color(0xFF00B28F), // Mint
    Color(0xFFFF6B8A), // Coral
    Color(0xFF5B7FFF), // Blue
    Color(0xFFFFB340), // Orange
    Color(0xFFA78BFA), // Lavender
    Color(0xFFFF5252), // Red
    Color(0xFF00BCD4), // Cyan
    Color(0xFFE040FB), // Pink
  ];

  Color avatarColor(String name) {
    if (name.isEmpty) return avatarColors[0];
    final index = name.codeUnitAt(0) % avatarColors.length;
    return avatarColors[index];
  }

  Color get accentAvatarStart => primary.withOpacity(0.2);
  Color get accentAvatarEnd => primary.withOpacity(0.2);

  // Borders
  Color get border => _isDarkMode ? Colors.white.withOpacity(0.15) : const Color(0x1A000000);
  Color get borderInput => primary;

  // Message Bubbles
  Color get msgMeBg => const Color(0xFF00796B);
  Color get msgOtherBg => _isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFEBEBEB);
  Color get msgMeText => Colors.white;
  Color get msgOtherText => _isDarkMode ? Colors.white : const Color(0xFF000000);
  Color get msgMeTime => Colors.white.withOpacity(0.65);
  Color get msgOtherTime => _isDarkMode ? Colors.white.withOpacity(0.4) : const Color(0xFF666666);

  // Status
  Color get online => const Color(0xFF22C55E);
  Color get onlineBorder => bgPrimary;

  // Icons & misc
  Color get iconMuted => _isDarkMode ? Colors.white.withOpacity(0.45) : const Color(0xFF8E8E93);
  Color get snackbarError => const Color(0xFFFF6B8A);
  Color get destructive => const Color(0xFFFF6B8A);

  ThemeData get themeData {
    return ThemeData(
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bgPrimary,
      colorScheme: _isDarkMode
          ? ColorScheme.dark(
              primary: primary,
              secondary: secondary,
              surface: const Color(0xFF1E1E1E),
            )
          : ColorScheme.light(
              primary: primary,
              secondary: secondary,
              surface: Colors.white,
            ),
      appBarTheme: AppBarTheme(
        backgroundColor: _isDarkMode ? bgPrimary : bgSecondary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _isDarkMode ? bgPrimary : bgSecondary,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgInput,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(100), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: TextStyle(color: textMuted),
        hintStyle: TextStyle(color: textDim),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: const CircleBorder(),
      ),
    );
  }
}
