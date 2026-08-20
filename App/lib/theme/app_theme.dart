import 'package:fitness_application/theme/app_colors.dart';
import 'package:fitness_application/theme/app_typography.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: AppColors.background,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: AppColors.background,
      surface: Colors.white,
      onSurface: AppColors.background,
      onSurfaceVariant: AppColors.neutral600,
      outline: Color(0xFFD9DEE0),
      error: AppColors.danger,
      onError: Colors.white,
    );

    return _build(colorScheme, Brightness.light);
  }

  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.background,
      secondary: AppColors.violet,
      onSecondary: Colors.white,
      surface: AppColors.background,
      onSurface: Colors.white,
      onSurfaceVariant: AppColors.neutral500,
      outline: AppColors.neutral800,
      error: AppColors.danger,
      onError: Colors.white,
    );

    return _build(colorScheme, Brightness.dark);
  }

  static ThemeData _build(ColorScheme colorScheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final surfaceContainer = isDark
        ? AppColors.neutral800
        : const Color(0xFFF4F6F6);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: AppTypography.textTheme(brightness: brightness),
      dividerTheme: DividerThemeData(color: colorScheme.outline),
      cardTheme: CardThemeData(color: surfaceContainer),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: isDark ? AppColors.accent : AppColors.background,
          foregroundColor: isDark ? AppColors.background : Colors.white,
          textStyle: AppTypography.textTheme(brightness: brightness).labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          textStyle: AppTypography.textTheme(brightness: brightness).labelLarge,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: isDark ? AppColors.accent : AppColors.background,
        labelTextStyle: WidgetStatePropertyAll(
          AppTypography.textTheme(brightness: brightness).labelMedium,
        ),
      ),
    );
  }
}
