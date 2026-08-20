import 'package:fitness_application/theme/app_colors.dart';
import 'package:fitness_application/theme/app_typography.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
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

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTypography.textTheme(),
      dividerTheme: const DividerThemeData(color: AppColors.neutral800),
      cardTheme: const CardThemeData(color: AppColors.neutral800),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.background,
          textStyle: AppTypography.textTheme().labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: const BorderSide(color: AppColors.neutral800),
          textStyle: AppTypography.textTheme().labelLarge,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.accent,
        labelTextStyle: WidgetStatePropertyAll(
          AppTypography.textTheme().labelMedium,
        ),
      ),
    );
  }
}
