import 'package:fitness_application/features/auth/presentation/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'renders the first welcome slide and advances through fake data',
    (tester) async {
      var started = false;

      await tester.pumpWidget(
        MaterialApp(
          home: WelcomeScreen(
            themeMode: ThemeMode.system,
            onThemeModeChanged: (_) {},
            onGetStarted: () => started = true,
          ),
        ),
      );

      expect(
        find.text('Wherever You Are\nHealth Is Number One'),
        findsOneWidget,
      );
      expect(
        find.text('There is no instant way to a healthy life'),
        findsOneWidget,
      );
      expect(find.text('Next'), findsOneWidget);
      expect(find.bySemanticsLabel('Welcome page 1 of 3'), findsOneWidget);
      expect(find.byTooltip('Change theme'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(
        find.text('Build Healthy Habits\nOne Day at a Time'),
        findsOneWidget,
      );
      expect(find.text('Next'), findsOneWidget);
      expect(find.bySemanticsLabel('Welcome page 2 of 3'), findsOneWidget);
      expect(started, isFalse);

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(
        find.text('Move With Your Community\nProgress Feels Better Together'),
        findsOneWidget,
      );
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.bySemanticsLabel('Welcome page 3 of 3'), findsOneWidget);

      await tester.tap(find.text('Get Started'));
      expect(started, isTrue);
    },
  );

  testWidgets('offers light, dark, and system theme choices', (tester) async {
    ThemeMode? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeScreen(
          themeMode: ThemeMode.system,
          onThemeModeChanged: (mode) => selected = mode,
          onGetStarted: () {},
        ),
      ),
    );

    await tester.tap(find.byTooltip('Change theme'));
    await tester.pumpAndSettle();

    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    expect(selected, ThemeMode.dark);
  });
}
