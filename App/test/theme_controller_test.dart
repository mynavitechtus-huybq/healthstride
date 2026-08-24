import 'package:fitness_application/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('persists the selected theme mode and restores it', () async {
    SharedPreferences.setMockInitialValues({
      ThemeController.storageKey: 'dark',
    });

    final preferences = await SharedPreferences.getInstance();
    final controller = ThemeController.fromPreferences(preferences);

    expect(controller.themeMode, ThemeMode.dark);
    await controller.setThemeMode(ThemeMode.light);

    final restored = ThemeController.fromPreferences(preferences);
    expect(restored.themeMode, ThemeMode.light);
  });

  test('uses system mode when no preference has been saved', () async {
    SharedPreferences.setMockInitialValues({});

    final preferences = await SharedPreferences.getInstance();
    final controller = ThemeController.fromPreferences(preferences);

    expect(controller.themeMode, ThemeMode.system);
  });
}
