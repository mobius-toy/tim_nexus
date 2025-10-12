import 'package:flutter/material.dart';

class AppTheme {
  static const Color _bgPrimary = Color(0xFF070B1A);
  static const Color _bgSecondary = Color(0xFF0E1425);
  static const Color _neonMint = Color(0xFF00F5C3);
  static const Color _deepPurple = Color(0xFF6C5CE7);
  static const Color _accentBlue = Color(0xFF367BFF);

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _neonMint,
      brightness: Brightness.dark,
      primary: _neonMint,
      secondary: _accentBlue,
      surface: _bgSecondary,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    );

    final textTheme = Typography.whiteMountainView.copyWith(
      displayLarge: const TextStyle(
        fontSize: 52,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.2,
      ),
      displayMedium: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.8,
      ),
      headlineSmall: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      titleLarge: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        height: 1.4,
        letterSpacing: 0.15,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        height: 1.4,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _bgPrimary,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black.withValues(alpha: 0.2),
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: Colors.white),
        centerTitle: false,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: _bgSecondary.withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        margin: const EdgeInsets.all(12),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _neonMint, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: Colors.white70),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          foregroundColor: Colors.black,
          backgroundColor: _neonMint,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        _AppDecorations(
          glassSurface: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x22FFFFFF),
              Color(0x0820FFE6),
            ],
          ),
          primaryGlow: RadialGradient(
            radius: 0.8,
            colors: [
              Color(0x3300F5C3),
              Color(0x0000F5C3),
            ],
          ),
        ),
      ],
    );
  }

  static Gradient backgroundGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      _bgPrimary,
      Color(0xFF02050F),
      _deepPurple,
    ],
    stops: [0.0, 0.6, 1.0],
  );
}

class _AppDecorations extends ThemeExtension<_AppDecorations> {
  const _AppDecorations({
    required this.glassSurface,
    required this.primaryGlow,
  });

  final Gradient glassSurface;
  final Gradient primaryGlow;

  @override
  ThemeExtension<_AppDecorations> copyWith({
    Gradient? glassSurface,
    Gradient? primaryGlow,
  }) {
    return _AppDecorations(
      glassSurface: glassSurface ?? this.glassSurface,
      primaryGlow: primaryGlow ?? this.primaryGlow,
    );
  }

  @override
  ThemeExtension<_AppDecorations> lerp(ThemeExtension<_AppDecorations>? other, double t) {
    if (other is! _AppDecorations) return this;
    return _AppDecorations(
      glassSurface: Gradient.lerp(glassSurface, other.glassSurface, t)!,
      primaryGlow: Gradient.lerp(primaryGlow, other.primaryGlow, t)!,
    );
  }
}
