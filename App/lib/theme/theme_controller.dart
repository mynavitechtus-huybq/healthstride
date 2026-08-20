import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._({required this._themeMode, this._preferences});

  factory ThemeController.fromPreferences(SharedPreferences preferences) {
    final savedMode = preferences.getString(storageKey);
    return ThemeController._(
      themeMode: _parse(savedMode),
      preferences: preferences,
    );
  }

  factory ThemeController.inMemory({ThemeMode themeMode = ThemeMode.system}) {
    return ThemeController._(themeMode: themeMode);
  }

  static const storageKey = 'theme_mode';

  final SharedPreferences? _preferences;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;

    _themeMode = themeMode;
    notifyListeners();
    await _preferences?.setString(storageKey, _serialize(themeMode));
  }

  static ThemeMode _parse(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static String _serialize(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}
