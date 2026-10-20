import 'package:flutter/material.dart';
import 'package:nic_backlog/data/models/game_model.dart';

/// VoiceBox Design System Tokens (https://designmd.ai/chef/voicebox)
/// Bold, opinionated, magazine-style.
class AppColors {
  AppColors._();

  // Brand Palette
  static const Color primary = Color(0xFF0A0A0A); // Black — headings, primary UI
  static const Color secondary = Color(0xFFEF4444); // Red — accent, emphasis
  static const Color tertiary = Color(0xFFFAFAFA); // White — backgrounds, inverse

  // Action Hover / Active
  static const Color secondaryHover = Color(0xFFDC2626);
  static const Color secondaryActive = Color(0xFFB91C1C);

  // Surface Palette
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color surfaceRaised = Color(0xFFE5E5E5);

  // Content Palette
  static const Color textPrimary = Color(0xFF0A0A0A);
  static const Color textSecondary = Color(0xFF525252);
  static const Color textTertiary = Color(0xFFA3A3A3);

  // Border Palette
  static const Color borderSubtle = Color(0xFFE5E5E5);
  static const Color borderMedium = Color(0xFFD4D4D4);
  static const Color borderStrong = Color(0xFF0A0A0A);

  // Semantic Colors
  static const Color success = Color(0xFF16A34A);
  static const Color successBg = Color(0xFFF0FDF4);
  static const Color warning = Color(0xFFCA8A04);
  static const Color warningBg = Color(0xFFFEFCE8);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF0A0A0A);
}

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle display = TextStyle(
    fontSize: 44,
    fontWeight: FontWeight.w900,
    height: 1.05,
    letterSpacing: -1.3,
    color: AppColors.textPrimary,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    height: 1.1,
    letterSpacing: -0.7,
    color: AppColors.textPrimary,
  );

  static const TextStyle subhead = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w900,
    height: 1.2,
    letterSpacing: -0.24,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.65,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0.12,
    color: AppColors.textSecondary,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.4,
    letterSpacing: 1.32,
    color: AppColors.textPrimary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.84,
    color: AppColors.tertiary,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get voiceBoxTheme {
    const zeroRadius = BorderRadius.zero;
    const sharpShape = RoundedRectangleBorder(borderRadius: zeroRadius);

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.tertiary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.tertiary,
        surface: AppColors.background,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: AppColors.tertiary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.tertiary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
          color: AppColors.tertiary,
        ),
        iconTheme: IconThemeData(color: AppColors.tertiary),
        shape: Border(
          bottom: BorderSide(color: AppColors.secondary, width: 3),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.background,
        elevation: 0,
        shape: sharpShape,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.background,
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: zeroRadius,
          side: BorderSide(color: AppColors.borderSubtle, width: 2),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.72,
          color: AppColors.textPrimary,
        ),
        floatingLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.72,
          color: AppColors.textPrimary,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiary,
        ),
        errorStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.error,
        ),
        border: OutlineInputBorder(
          borderRadius: zeroRadius,
          borderSide: BorderSide(color: AppColors.borderMedium, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: zeroRadius,
          borderSide: BorderSide(color: AppColors.borderMedium, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: zeroRadius,
          borderSide: BorderSide(color: AppColors.borderStrong, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: zeroRadius,
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: zeroRadius,
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        prefixIconColor: AppColors.textPrimary,
        suffixIconColor: AppColors.textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.tertiary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.35),
          disabledForegroundColor: AppColors.tertiary.withValues(alpha: 0.7),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: zeroRadius,
            side: BorderSide(color: AppColors.primary, width: 2),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: AppColors.primary, width: 2),
          shape: sharpShape,
          textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: sharpShape,
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.78,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.tertiary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: zeroRadius,
          side: BorderSide(color: AppColors.primary, width: 2),
        ),
        extendedTextStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.84,
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.surface,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.66,
          color: AppColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: zeroRadius,
          side: BorderSide(color: AppColors.borderMedium, width: 2),
        ),
        elevation: 0,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: zeroRadius,
          side: BorderSide(color: AppColors.borderStrong, width: 2),
        ),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
        ),
        contentTextStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: AppColors.background,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: zeroRadius,
          side: BorderSide(color: AppColors.borderStrong, width: 2),
        ),
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.primary,
        contentTextStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: AppColors.tertiary,
        ),
        elevation: 0,
        shape: sharpShape,
        behavior: SnackBarBehavior.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 2,
        space: 24,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }

  /// Builds a VoiceBox Status Chip according to GameStatus
  static Widget buildStatusChip(GameStatus status) {
    final (Color bg, Color fg, Color border) = switch (status) {
      GameStatus.completed => (
        AppColors.successBg,
        AppColors.success,
        AppColors.success,
      ),
      GameStatus.playing => (
        AppColors.warningBg,
        AppColors.warning,
        AppColors.warning,
      ),
      GameStatus.dropped => (
        AppColors.errorBg,
        AppColors.error,
        AppColors.error,
      ),
      GameStatus.backlogged => (
        AppColors.surface,
        AppColors.textPrimary,
        AppColors.borderStrong,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 2),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.66,
          color: fg,
        ),
      ),
    );
  }
}
