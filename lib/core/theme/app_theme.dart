import 'package:flutter/material.dart';

class AppTheme {
  // 与 tim_nexus web 完全一致的深色主题配色 - 基于 OKLCH 颜色空间
  static const Color _background = Color(0xFF252525); // oklch(0.145 0 0) - 主背景
  static const Color _foreground = Color(0xFFFBFBFB); // oklch(0.985 0 0) - 主要文本
  static const Color _card = Color(0xFF343434); // oklch(0.205 0 0) - 卡片背景
  static const Color _cardForeground = Color(0xFFFBFBFB); // oklch(0.985 0 0) - 卡片文本
  static const Color _secondary = Color(0xFF444444); // oklch(0.269 0 0) - 次要背景
  static const Color _secondaryForeground = Color(0xFFFBFBFB); // oklch(0.985 0 0) - 次要文本
  static const Color _mutedForeground = Color(0xFFB5B5B5); // oklch(0.708 0 0) - 静音文本
  static const Color _accent = Color(0xFF444444); // oklch(0.269 0 0) - 强调背景
  static const Color _accentForeground = Color(0xFFFBFBFB); // oklch(0.985 0 0) - 强调文本
  static const Color _border = Color(0x1AFFFFFF); // oklch(1 0 0 / 10%) - 边框
  static const Color _input = Color(0x26FFFFFF); // oklch(1 0 0 / 15%) - 输入框
  static const Color _ring = Color(0xFF8E8E8E); // oklch(0.556 0 0) - 焦点环
  static const Color _primary = Color(0xFFEBEBEB); // oklch(0.922 0 0) - 主要颜色
  static const Color _primaryForeground = Color(0xFF343434); // oklch(0.205 0 0) - 主要颜色前景
  static const Color _destructive = Color(0xFFE57373); // oklch(0.704 0.191 22.216) - 破坏性颜色

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.dark,
      primary: _primary,
      secondary: _secondary,
      surface: _card,
      onPrimary: _primaryForeground,
      onSecondary: _secondaryForeground,
      onSurface: _cardForeground,
      error: _destructive,
    );

    final textTheme = Typography.whiteMountainView.copyWith(
      displayLarge: const TextStyle(
        fontSize: 52,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.2,
        color: _foreground,
      ),
      displayMedium: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.8,
        color: _foreground,
      ),
      headlineSmall: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: _foreground,
      ),
      titleLarge: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: _foreground,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        height: 1.4,
        letterSpacing: 0.15,
        color: _foreground,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        height: 1.4,
        color: _mutedForeground,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w500,
        color: _foreground,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _background,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: _foreground),
        centerTitle: false,
        foregroundColor: _foreground,
      ),
      cardTheme: CardTheme(
        color: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        margin: const EdgeInsets.all(8),
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _input,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _ring, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        labelStyle: const TextStyle(color: _mutedForeground),
        hintStyle: const TextStyle(color: _mutedForeground),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          foregroundColor: _accentForeground,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ),
      extensions: const <ThemeExtension<dynamic>>[
        _AppDecorations(
          glassSurface: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0x0AFFFFFF),
              Color(0x05FFFFFF),
            ],
          ),
          primaryGlow: RadialGradient(
            radius: 0.8,
            colors: [
              Color(0x1A8E8E8E),
              Color(0x008E8E8E),
            ],
          ),
        ),
      ],
      // 添加更多主题配置以完善深色主题
      dividerTheme: const DividerThemeData(
        color: Color(0x1AFFFFFF),
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: _foreground,
        size: 24,
      ),
      listTileTheme: const ListTileThemeData(
        textColor: _foreground,
        iconColor: _foreground,
        tileColor: Colors.transparent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _foreground;
          }
          return _mutedForeground;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _accent;
          }
          return _secondary;
        }),
      ),
      // 添加 popover 主题配置
      popupMenuTheme: const PopupMenuThemeData(
        color: _card,
        textStyle: TextStyle(color: _foreground),
      ),
      // 添加 dialog 主题配置
      dialogTheme: const DialogTheme(
        titleTextStyle: TextStyle(
          color: _foreground,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: _foreground,
          fontSize: 16,
        ),
      ),
      // 添加 bottom sheet 主题配置
      bottomSheetTheme: const BottomSheetThemeData(
        modalBackgroundColor: _card,
      ),
    );
  }

  static Gradient backgroundGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      _background,
      _background,
    ],
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
