import 'package:fitness_application/theme/app_colors.dart';
import 'package:fitness_application/theme/theme_mode_picker.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.onGetStarted,
    super.key,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 57,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/welcome_hero.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          background.withValues(alpha: 0.08),
                          background,
                        ],
                        stops: const [0.48, 0.76, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 12,
                    child: ThemeModePickerButton(
                      themeMode: themeMode,
                      onThemeModeChanged: onThemeModeChanged,
                      style: IconButton.styleFrom(
                        backgroundColor: background.withValues(alpha: 0.78),
                        foregroundColor: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 43,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: 'Wherever You Are\n'),
                          TextSpan(
                            text: 'Health Is Number One',
                            style: TextStyle(
                              backgroundColor: AppColors.accent,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800, height: 1.12),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'There is no instant way to a healthy life',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    const _WelcomeIndicator(),
                    const SizedBox(height: 42),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: onGetStarted,
                        child: const Text('Get Started'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeIndicator extends StatelessWidget {
  const _WelcomeIndicator();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 65,
      height: 5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 21,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    );
  }
}
