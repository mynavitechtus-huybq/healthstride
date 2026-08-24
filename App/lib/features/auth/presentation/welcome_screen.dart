import 'package:fitness_application/theme/app_colors.dart';
import 'package:fitness_application/theme/theme_mode_picker.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
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
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  _WelcomeSlide get _slide => welcomeSlides[_currentPage];
  bool get _isLastPage => _currentPage == welcomeSlides.length - 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChanged(int page) {
    if (page == _currentPage) return;
    setState(() => _currentPage = page);
  }

  Future<void> _goToNextPage() async {
    if (_isLastPage) {
      widget.onGetStarted();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

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
                  PageView.builder(
                    controller: _pageController,
                    itemCount: welcomeSlides.length,
                    onPageChanged: _handlePageChanged,
                    itemBuilder: (context, index) => Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          welcomeSlides[index].imageAsset,
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
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 12,
                    child: ThemeModePickerButton(
                      themeMode: widget.themeMode,
                      onThemeModeChanged: widget.onThemeModeChanged,
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
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text.rich(
                        key: ValueKey(_slide.title),
                        TextSpan(
                          children: [
                            TextSpan(text: '${_slide.title}\n'),
                            TextSpan(
                              text: _slide.highlight,
                              style: TextStyle(
                                backgroundColor: AppColors.accent,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.12,
                            ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Text(
                        _slide.description,
                        key: ValueKey(_slide.description),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _WelcomeIndicator(currentPage: _currentPage),
                    const SizedBox(height: 42),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _goToNextPage,
                        child: Text(_isLastPage ? 'Get Started' : 'Next'),
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

class _WelcomeSlide {
  const _WelcomeSlide({
    required this.title,
    required this.highlight,
    required this.description,
    required this.imageAsset,
  });

  final String title;
  final String highlight;
  final String description;
  final String imageAsset;
}

const welcomeSlides = [
  _WelcomeSlide(
    title: 'Wherever You Are',
    highlight: 'Health Is Number One',
    description: 'There is no instant way to a healthy life',
    imageAsset: 'assets/images/welcome_hero.jpg',
  ),
  _WelcomeSlide(
    title: 'Build Healthy Habits',
    highlight: 'One Day at a Time',
    description: 'Small steps become a stronger, healthier routine',
    imageAsset: 'assets/images/welcome_hero.jpg',
  ),
  _WelcomeSlide(
    title: 'Move With Your Community',
    highlight: 'Progress Feels Better Together',
    description: 'Stay motivated and celebrate every milestone',
    imageAsset: 'assets/images/welcome_hero.jpg',
  ),
];

class _WelcomeIndicator extends StatelessWidget {
  const _WelcomeIndicator({required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Welcome page ${currentPage + 1} of ${welcomeSlides.length}',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < welcomeSlides.length; index++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: index == currentPage ? 21 : 10,
                height: index == currentPage ? 5 : 3,
                decoration: BoxDecoration(
                  color: index == currentPage
                      ? AppColors.accent
                      : Theme.of(context).colorScheme.onSurface,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
