---
title: 'HealthStride: flutter design system theme plan'
description: 'Nhật ký và tài liệu tham chiếu của dự án HealthStride.'
---
# Flutter Design System Theme Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply the approved Figma design system as the Material 3 dark theme for the Flutter Fitness Application.

**Architecture:** Foundation colors and typography live in focused `lib/theme/` modules. `AppTheme.dark()` composes them into the only `ThemeData` instance consumed by `MyApp`; UI reads semantic roles from `Theme.of(context)` rather than hard-coded design values.

**Tech Stack:** Flutter 3.44.9, Dart 3.12.2, Material 3, bundled Lato font assets, `flutter_test`.

## Global Constraints

- Use only Figma node `1:2` values documented in `Document/DESIGN-SYSTEM.md`.
- Use Lato weights 400, 500, 600, 700, and 800 from bundled assets; do not add runtime font downloads or the `google_fonts` package.
- Use `#192126` as the dark app canvas and `#BBF246` as the primary accent.
- Keep `#A48AED`, `#ED4747`, `#FCC46F`, and `#95CCE3` for semantic/chart usage, not generic primary CTAs.
- Do not modify Backend, Android, or iOS project configuration.
- Keep the initial `Hello Application` screen functional.
- The workspace has no Git repository; do not initialize Git or attempt commits.

---

### Task 1: Bundle Lato Font Assets and Register Them

**Files:**
- Create: `App/assets/fonts/Lato-Regular.ttf`
- Create: `App/assets/fonts/Lato-Medium.ttf`
- Create: `App/assets/fonts/Lato-SemiBold.ttf`
- Create: `App/assets/fonts/Lato-Bold.ttf`
- Create: `App/assets/fonts/Lato-ExtraBold.ttf`
- Modify: `App/pubspec.yaml`
- Test: none; asset registration is exercised by the typography tests in Task 2

**Interfaces:**
- Consumes: the five Lato font weights specified in `Document/DESIGN-SYSTEM.md`
- Produces: Flutter font family name `Lato`, usable by `TextTheme.apply(fontFamily: 'Lato')`

- [ ] **Step 1: Add the five Lato TTF files and register one Lato family**

Download the static fonts from the Google Fonts Lato family into
`App/assets/fonts/` with these exact filenames:

```bash
curl -fL -o assets/fonts/Lato-Regular.ttf https://github.com/google/fonts/raw/main/ofl/lato/Lato-Regular.ttf
curl -fL -o assets/fonts/Lato-Medium.ttf https://github.com/google/fonts/raw/main/ofl/lato/Lato-Medium.ttf
curl -fL -o assets/fonts/Lato-SemiBold.ttf https://github.com/google/fonts/raw/main/ofl/lato/Lato-SemiBold.ttf
curl -fL -o assets/fonts/Lato-Bold.ttf https://github.com/google/fonts/raw/main/ofl/lato/Lato-Bold.ttf
curl -fL -o assets/fonts/Lato-ExtraBold.ttf https://github.com/google/fonts/raw/main/ofl/lato/Lato-ExtraBold.ttf
```

Add this under the existing `flutter:` section in `pubspec.yaml`:

```yaml
  fonts:
    - family: Lato
      fonts:
        - asset: assets/fonts/Lato-Regular.ttf
          weight: 400
        - asset: assets/fonts/Lato-Medium.ttf
          weight: 500
        - asset: assets/fonts/Lato-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Lato-Bold.ttf
          weight: 700
        - asset: assets/fonts/Lato-ExtraBold.ttf
          weight: 800
```

- [ ] **Step 2: Fetch dependencies and verify the asset declaration**

Run:

```bash
flutter pub get
dart pub deps --style=compact
```

Expected: `flutter pub get` succeeds. The Lato family behavior is verified by
the Task 2 typography test after the theme module consumes this declaration.

### Task 2: Define Foundation Colors and Lato Typography

**Files:**
- Create: `App/lib/theme/app_colors.dart`
- Create: `App/lib/theme/app_typography.dart`
- Test: `App/test/app_theme_test.dart`

**Interfaces:**
- Consumes: Figma color and type tokens from `Document/DESIGN-SYSTEM.md`
- Produces: `AppColors` static `Color` constants and `AppTypography.textTheme()` returning a Material 3 `TextTheme`

- [ ] **Step 1: Write failing unit tests for foundation tokens**

```dart
import 'package:fitness_application/theme/app_colors.dart';
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
}
```

- [ ] **Step 2: Run the new unit tests before implementation**

Run:

```bash
flutter test test/app_theme_test.dart
```

Expected: FAIL because the theme modules do not exist.

- [ ] **Step 3: Implement immutable Figma color constants**

```dart
abstract final class AppColors {
  static const background = Color(0xFF192126);
  static const accent = Color(0xFFBBF246);
  static const neutral500 = Color(0xFF8B8F92);
  static const neutral600 = Color(0xFF5E6468);
  static const neutral800 = Color(0xFF384046);
  static const violet = Color(0xFFA48AED);
  static const danger = Color(0xFFED4747);
  static const warning = Color(0xFFFCC46F);
  static const info = Color(0xFF95CCE3);
}
```

- [ ] **Step 4: Implement the Lato Material 3 text theme**

Implement this exact structure in `app_typography.dart`:

```dart
abstract final class AppTypography {
  static TextTheme textTheme() {
    final base = Typography.material2021().white.apply(fontFamily: 'Lato');

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontWeight: FontWeight.w800),
      displayMedium: base.displayMedium?.copyWith(fontWeight: FontWeight.w800),
      displaySmall: base.displaySmall?.copyWith(fontWeight: FontWeight.w800),
      headlineLarge: base.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: base.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
      bodyMedium: base.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
      bodySmall: base.bodySmall?.copyWith(fontWeight: FontWeight.w400),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w500),
      labelSmall: base.labelSmall?.copyWith(fontWeight: FontWeight.w500),
    );
  }
}
```

- [ ] **Step 5: Run the foundation tests**

Run:

```bash
flutter test test/app_theme_test.dart
```

Expected: PASS with the exact Figma colors and Lato weights.

### Task 3: Compose the Material 3 Theme and Adopt It in the App

**Files:**
- Create: `App/lib/theme/app_theme.dart`
- Modify: `App/lib/main.dart`
- Modify: `App/test/widget_test.dart`
- Modify: `App/test/app_theme_test.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppTypography.textTheme()`
- Produces: `AppTheme.dark()` returning `ThemeData`, then used by `MyApp`

- [ ] **Step 1: Add a failing theme-composition test**

```dart
import 'package:fitness_application/theme/app_theme.dart';

test('maps Figma tokens to Material 3 dark semantic roles', () {
  final theme = AppTheme.dark();

  expect(theme.useMaterial3, isTrue);
  expect(theme.brightness, Brightness.dark);
  expect(theme.scaffoldBackgroundColor, const Color(0xFF192126));
  expect(theme.colorScheme.primary, const Color(0xFFBBF246));
  expect(theme.colorScheme.onPrimary, const Color(0xFF192126));
  expect(theme.colorScheme.error, const Color(0xFFED4747));
});
```

- [ ] **Step 2: Run the theme test before implementation**

Run:

```bash
flutter test test/app_theme_test.dart
```

Expected: FAIL because `AppTheme` does not exist.

- [ ] **Step 3: Implement `AppTheme.dark()` and component defaults**

Implement this composition, retaining the exact foundation values in
`AppColors`:

```dart
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
```

- [ ] **Step 4: Replace the seed theme in `MyApp`**

Replace:

```dart
theme: ThemeData(
  colorScheme: .fromSeed(seedColor: Colors.teal),
),
```

With:

```dart
theme: AppTheme.dark(),
```

Import `package:fitness_application/theme/app_theme.dart`.

- [ ] **Step 5: Expand the widget test for the adopted theme**

Keep the greeting assertion and add:

```dart
final context = tester.element(find.text('Hello Application'));
expect(Theme.of(context).colorScheme.primary, const Color(0xFFBBF246));
expect(Theme.of(context).scaffoldBackgroundColor, const Color(0xFF192126));
```

- [ ] **Step 6: Run the full test suite and static analysis**

Run:

```bash
flutter test
flutter analyze
```

Expected: all tests pass and analyzer reports no issues.

### Task 4: Verify the Theme on iOS and Android

**Files:**
- Modify: none
- Test: iPhone Simulator and Android `Fitness_API_35` emulator

**Interfaces:**
- Consumes: the themed Flutter application from Task 3
- Produces: visual proof that dark canvas, accent, Lato text, and greeting render on both platforms

- [ ] **Step 1: Run on the currently booted iPhone Simulator**

Run from `App` using the exact ID currently printed by `flutter devices`:

```bash
flutter run -d <current-ios-simulator-id>
```

Expected: the app launches with the dark `#192126` canvas, Lato greeting, and
accent theme behavior without an Xcode build error.

- [ ] **Step 2: Run on Android API 35**

Run:

```bash
flutter run -d emulator-5554
```

Expected: the same dark Material 3 theme appears on the embedded Android
emulator.

- [ ] **Step 3: Check the visual contract on both devices**

Verify that `Hello Application` is readable against the dark canvas, no teal
seed color remains, and no text or icon relies on color alone to communicate a
state.

## Completion Criteria

The app uses `AppTheme.dark()`; Lato is bundled locally at all five Figma
weights; foundation and semantic colors match `DESIGN-SYSTEM.md`; tests and
analysis pass; and the app is visually verified on both iOS and Android.
