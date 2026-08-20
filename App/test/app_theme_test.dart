import 'package:fitness_application/theme/app_colors.dart';
import 'package:fitness_application/theme/app_theme.dart';
import 'package:fitness_application/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exposes the Figma primary colors', () {
    expect(AppColors.background, const Color(0xFF192126));
    expect(AppColors.accent, const Color(0xFFBBF246));
  });

  test('builds a Lato text theme with the specified display weight', () {
    final theme = AppTypography.textTheme();

    expect(theme.displaySmall?.fontFamily, 'Lato');
    expect(theme.displaySmall?.fontWeight, FontWeight.w800);
    expect(theme.bodyMedium?.fontWeight, FontWeight.w400);
  });

  test('maps Figma tokens to Material 3 dark semantic roles', () {
    final theme = AppTheme.dark();

    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, const Color(0xFF192126));
    expect(theme.colorScheme.primary, const Color(0xFFBBF246));
    expect(theme.colorScheme.onPrimary, const Color(0xFF192126));
    expect(theme.colorScheme.error, const Color(0xFFED4747));
  });
}
