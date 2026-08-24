import 'package:fitness_application/theme/app_colors.dart';
import 'package:fitness_application/theme/theme_mode_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../domain/home_dashboard.dart';
import '../../leaderboard/domain/leaderboard_repository.dart';
import '../../leaderboard/presentation/leaderboard_controller.dart';
import '../../leaderboard/presentation/leaderboard_screen.dart';
import 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.controller,
    required this.onSignOut,
    this.leaderboardRepository,
    this.themeMode = ThemeMode.system,
    this.onThemeModeChanged,
    super.key,
  });

  final HomeController controller;
  final Future<void> Function() onSignOut;
  final LeaderboardRepository? leaderboardRepository;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Object? _snackBarFailureToken;
  var _selectedTab = 0;
  LeaderboardController? _leaderboardController;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
    if (widget.leaderboardRepository != null) {
      _leaderboardController = LeaderboardController(
        repository: widget.leaderboardRepository!,
      );
    }
    widget.controller.load();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;

    oldWidget.controller.removeListener(_handleControllerChanged);
    _snackBarFailureToken = null;
    widget.controller.addListener(_handleControllerChanged);
    widget.controller.load();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleControllerChanged);
    _leaderboardController?.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (!mounted) return;

    final state = widget.controller.value;
    if (state.failure == null) {
      _snackBarFailureToken = null;
      return;
    }

    if (state.dashboard == null ||
        identical(_snackBarFailureToken, state.failure)) {
      return;
    }

    _snackBarFailureToken = state.failure;
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Unable to refresh your dashboard.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _selectedTab == 1 && _leaderboardController != null
            ? LeaderboardScreen(
                controller: _leaderboardController!,
                embedded: true,
              )
            : _selectedTab == 0
            ? ValueListenableBuilder<HomeViewState>(
                valueListenable: widget.controller,
                builder: (context, state, child) {
                  if (state.isInitialLoading && state.dashboard == null) {
                    return const _HomeLoadingView();
                  }

                  if (state.dashboard == null) {
                    return _HomeErrorView(onRetry: widget.controller.retry);
                  }

                  return _HomeDashboardView(
                    state: state,
                    onRefresh: widget.controller.refresh,
                    themeMode: widget.themeMode,
                    onThemeModeChanged: widget.onThemeModeChanged,
                    onSignOut: widget.onSignOut,
                  );
                },
              )
            : _ComingSoonView(label: _tabLabel(_selectedTab)),
      ),
      bottomNavigationBar: _HomeBottomNavigation(
        selectedIndex: _selectedTab,
        onTap: (index) {
          if (index == _selectedTab) return;
          setState(() => _selectedTab = index);
          if (index == 1) _leaderboardController?.load();
        },
      ),
    );
  }
}

class _HomeDashboardView extends StatefulWidget {
  const _HomeDashboardView({
    required this.state,
    required this.onRefresh,
    required this.onSignOut,
    required this.themeMode,
    this.onThemeModeChanged,
  });

  final HomeViewState state;
  final RefreshCallback onRefresh;
  final Future<void> Function() onSignOut;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  State<_HomeDashboardView> createState() => _HomeDashboardViewState();
}

class _HomeDashboardViewState extends State<_HomeDashboardView> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WorkoutSummary> get _popularWorkouts {
    final workouts = widget.state.dashboard!.popularWorkouts;
    return workouts.isEmpty ? _fallbackPopularWorkouts : workouts;
  }

  List<WorkoutSummary> get _filteredPopularWorkouts {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _popularWorkouts;

    return _popularWorkouts
        .where(
          (workout) =>
              workout.name.toLowerCase().contains(query) ||
              workout.description.toLowerCase().contains(query) ||
              workout.workoutType.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  List<WorkoutSummary> get _todayPlans {
    final dashboard = widget.state.dashboard!;
    final plans = <WorkoutSummary>[];
    if (dashboard.todayPlan != null) plans.add(dashboard.todayPlan!);
    for (final workout in _popularWorkouts) {
      if (plans.length == 3) break;
      if (plans.every((plan) => plan.slug != workout.slug)) plans.add(workout);
    }
    for (final fallback in _fallbackTodayPlans) {
      if (plans.length == 3) break;
      if (plans.every((plan) => plan.slug != fallback.slug)) {
        plans.add(fallback);
      }
    }
    return plans;
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = widget.state.dashboard!;
    final profile = dashboard.profile;
    final displayName = _greetingName(profile);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 112),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good Morning 🔥', style: textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(
                      displayName,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.onThemeModeChanged != null)
                ThemeModePickerButton(
                  themeMode: widget.themeMode,
                  onThemeModeChanged: widget.onThemeModeChanged!,
                ),
              IconButton(
                onPressed: widget.onSignOut,
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Sign out',
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            key: const ValueKey('home-search-field'),
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle(title: 'Popular Workouts'),
          const SizedBox(height: 12),
          SizedBox(
            height: 174,
            child: _filteredPopularWorkouts.isEmpty
                ? _EmptyInlineMessage(
                    message: 'No workouts match your search.',
                    width: double.infinity,
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filteredPopularWorkouts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 20),
                    itemBuilder: (context, index) => _PopularWorkoutCard(
                      workout: _filteredPopularWorkouts[index],
                      index: index,
                    ),
                  ),
          ),
          const SizedBox(height: 28),
          _SectionTitle(title: 'Today Plan'),
          const SizedBox(height: 12),
          ..._todayPlans.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TodayPlanCard(workout: entry.value, index: entry.key),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _PopularWorkoutCard extends StatelessWidget {
  const _PopularWorkoutCard({required this.workout, required this.index});

  final WorkoutSummary workout;
  final int index;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _WorkoutImage(workout: workout, popular: true),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xB3000000), Colors.transparent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Positioned(
              top: 18,
              left: 20,
              right: 72,
              child: Text(
                _popularTitle(workout, index),
                maxLines: 2,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 18,
              child: Row(
                children: [
                  _WorkoutChip(
                    icon: Icons.local_fire_department_outlined,
                    label: '${workout.estimatedCalories} Kcal',
                  ),
                  const SizedBox(width: 8),
                  _WorkoutChip(
                    icon: Icons.timer_outlined,
                    label: '${workout.durationMinutes} Min',
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              top: 68,
              child: SvgPicture.asset(
                'assets/home/icons/play.svg',
                width: 38,
                height: 38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutChip extends StatelessWidget {
  const _WorkoutChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.background),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.background),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayPlanCard extends StatelessWidget {
  const _TodayPlanCard({required this.workout, required this.index});

  final WorkoutSummary workout;
  final int index;

  @override
  Widget build(BuildContext context) {
    final progress = [0.45, 0.75, 0.45][index % 3];
    final difficulty = index == 0 ? 'Intermediate' : 'Beginner';

    return SizedBox(
      height: 120,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(23),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: _WorkoutImage(workout: workout),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, right: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              workout.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const Spacer(),
                            _ProgressBar(progress: progress),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: Text(
                    difficulty,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 16,
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: const Color(0xFFF2F2F2),
          color: AppColors.accent,
          valueColor: const AlwaysStoppedAnimation(AppColors.accent),
        ),
      ),
    );
  }
}

class _WorkoutImage extends StatelessWidget {
  const _WorkoutImage({required this.workout, this.popular = false});

  final WorkoutSummary workout;
  final bool popular;

  @override
  Widget build(BuildContext context) {
    final fallback = _workoutAsset(workout, popular: popular);
    final imageUrl = workout.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset(fallback, fit: BoxFit.cover);
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          Image.asset(fallback, fit: BoxFit.cover),
    );
  }
}

class _EmptyInlineMessage extends StatelessWidget {
  const _EmptyInlineMessage({required this.message, required this.width});

  final String message;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(child: Text(message)),
      ),
    );
  }
}

class _HomeLoadingView extends StatelessWidget {
  const _HomeLoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('home-loading-view'),
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 24),
        _LoadingBlock(height: 18, width: 120),
        const SizedBox(height: 8),
        _LoadingBlock(height: 32, width: 210),
        const SizedBox(height: 24),
        _LoadingBlock(height: 48),
        const SizedBox(height: 24),
        _LoadingBlock(height: 174),
        const SizedBox(height: 28),
        _LoadingBlock(height: 120),
        const SizedBox(height: 12),
        _LoadingBlock(height: 120),
      ],
    );
  }
}

class _LoadingBlock extends StatelessWidget {
  const _LoadingBlock({required this.height, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _HomeErrorView extends StatelessWidget {
  const _HomeErrorView({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Unable to load your dashboard.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Check your connection and try again.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeBottomNavigation extends StatelessWidget {
  const _HomeBottomNavigation({
    required this.onTap,
    required this.selectedIndex,
  });

  final ValueChanged<int> onTap;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final iconPaths = [
      'assets/home/icons/home.svg',
      'assets/home/icons/explore.svg',
      'assets/home/icons/statistics.svg',
      'assets/home/icons/profile.svg',
    ];
    final labels = ['Home', 'Explore', 'Statistics', 'Profile'];

    return Container(
      margin: const EdgeInsets.fromLTRB(25, 0, 25, 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var index = 0; index < labels.length; index++)
            Tooltip(
              message: labels[index],
              child: IconButton(
                onPressed: () => onTap(index),
                icon: index == selectedIndex
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(43),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                iconPaths[index],
                                width: 24,
                                height: 24,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Home',
                                style: TextStyle(
                                  color: AppColors.background,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SvgPicture.asset(iconPaths[index], width: 24, height: 24),
              ),
            ),
        ],
      ),
    );
  }
}

class _ComingSoonView extends StatelessWidget {
  const _ComingSoonView({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$label is coming soon.',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

String _tabLabel(int index) =>
    const ['Home', 'Explore', 'Statistics', 'Profile'][index];

String _greetingName(HomeProfile profile) {
  final displayName = profile.displayName.trim();
  if (displayName.isNotEmpty) return displayName;

  final email = profile.email.trim();
  if (email.isNotEmpty) return email;

  return 'Athlete';
}

String _popularTitle(WorkoutSummary workout, int index) {
  if (workout.name.trim().isNotEmpty) return workout.name;
  return index == 0 ? 'Lower Body Training' : 'Hand Training';
}

String _workoutAsset(WorkoutSummary workout, {required bool popular}) {
  final name = '${workout.name} ${workout.workoutType}'.toLowerCase();
  if (name.contains('push')) return 'assets/home/plan_push_up.jpg';
  if (name.contains('sit')) return 'assets/home/plan_sit_up.jpg';
  if (name.contains('knee')) return 'assets/home/plan_knee_push_up.jpg';
  if (popular && name.contains('hand')) {
    return 'assets/home/popular_hand_training.jpg';
  }
  return popular
      ? 'assets/home/popular_lower_body.jpg'
      : 'assets/home/plan_knee_push_up.jpg';
}

const _fallbackPopularWorkouts = [
  WorkoutSummary(
    slug: 'lower-body-training',
    name: 'Lower Body Training',
    description: 'Build strength in your lower body.',
    workoutType: 'strength',
    durationMinutes: 50,
    estimatedCalories: 500,
    imageUrl: null,
  ),
  WorkoutSummary(
    slug: 'hand-training',
    name: 'Hand Training',
    description: 'Build upper body strength.',
    workoutType: 'strength',
    durationMinutes: 40,
    estimatedCalories: 600,
    imageUrl: null,
  ),
];

const _fallbackTodayPlans = [
  WorkoutSummary(
    slug: 'push-up',
    name: 'Push Up',
    description: '100 Push up a day',
    workoutType: 'strength',
    durationMinutes: 20,
    estimatedCalories: 120,
    imageUrl: null,
  ),
  WorkoutSummary(
    slug: 'sit-up',
    name: 'Sit Up',
    description: '20 Sit up a day',
    workoutType: 'strength',
    durationMinutes: 20,
    estimatedCalories: 90,
    imageUrl: null,
  ),
  WorkoutSummary(
    slug: 'knee-push-up',
    name: 'Knee Push Up',
    description: '20 Sit up a day',
    workoutType: 'strength',
    durationMinutes: 15,
    estimatedCalories: 80,
    imageUrl: null,
  ),
];
