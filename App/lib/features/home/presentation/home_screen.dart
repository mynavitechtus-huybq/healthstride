import 'package:fitness_application/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../domain/home_dashboard.dart';
import 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.controller,
    required this.onSignOut,
    super.key,
  });

  final HomeController controller;
  final Future<void> Function() onSignOut;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Object? _snackBarFailureToken;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleControllerChanged);
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
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              widget.onSignOut();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: ValueListenableBuilder<HomeViewState>(
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
          );
        },
      ),
    );
  }
}

class _HomeDashboardView extends StatelessWidget {
  const _HomeDashboardView({required this.state, required this.onRefresh});

  final HomeViewState state;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final dashboard = state.dashboard!;
    final textTheme = Theme.of(context).textTheme;
    final displayName = dashboard.profile.displayName.trim().isEmpty
        ? dashboard.profile.email
        : dashboard.profile.displayName;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: [
          Text('Welcome back, $displayName', style: textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Keep your streak moving with today\'s training snapshot.',
            style: textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: state.isRefreshing
                ? const Padding(
                    key: ValueKey('refreshing-indicator'),
                    padding: EdgeInsets.only(bottom: 20),
                    child: LinearProgressIndicator(minHeight: 4),
                  )
                : const SizedBox(key: ValueKey('refreshing-spacer'), height: 4),
          ),
          const SizedBox(height: 20),
          _MetricsSection(profile: dashboard.profile),
          const SizedBox(height: 28),
          const _SectionHeader(
            title: 'Today\'s Plan',
            subtitle: 'A focused workout you can complete today.',
          ),
          const SizedBox(height: 12),
          _TodayPlanCard(workout: dashboard.todayPlan),
          const SizedBox(height: 28),
          const _SectionHeader(
            title: 'Popular Workouts',
            subtitle: 'Build momentum with sessions other members revisit.',
          ),
          const SizedBox(height: 12),
          if (dashboard.popularWorkouts.isEmpty)
            const _SectionMessage('No workouts available right now.')
          else
            ...dashboard.popularWorkouts.map(
              (workout) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WorkoutCard(workout: workout),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricsSection extends StatelessWidget {
  const _MetricsSection({required this.profile});

  final HomeProfile profile;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      ('Lifetime points', profile.lifetimePoints.toString(), AppColors.accent),
      ('Available points', profile.availablePoints.toString(), AppColors.info),
      ('Day streak', profile.currentStreak.toString(), AppColors.warning),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final itemWidth = isWide
            ? (constraints.maxWidth - 24) / 3
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: metrics
              .map(
                (metric) => SizedBox(
                  width: itemWidth,
                  child: _MetricCard(
                    label: metric.$1,
                    value: metric.$2,
                    accentColor: metric.$3,
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.neutral800,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 92),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: textTheme.headlineSmall?.copyWith(color: accentColor),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayPlanCard extends StatelessWidget {
  const _TodayPlanCard({required this.workout});

  final WorkoutSummary? workout;

  @override
  Widget build(BuildContext context) {
    if (workout == null) {
      return const _SectionMessage('No plan for today yet.');
    }

    return _WorkoutCard(workout: workout!, supportingLabel: 'Today');
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.workout, this.supportingLabel});

  final WorkoutSummary workout;
  final String? supportingLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final icon = _workoutIcon(workout.workoutType);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.neutral800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.accent),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (supportingLabel != null) ...[
                    Text(
                      supportingLabel!,
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(workout.name, style: textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    workout.description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _WorkoutFact(
                        icon: Icons.schedule,
                        label: '${workout.durationMinutes} min',
                      ),
                      _WorkoutFact(
                        icon: Icons.local_fire_department_outlined,
                        label: '${workout.estimatedCalories} cal',
                      ),
                      _WorkoutFact(
                        icon: icon,
                        label: _formatWorkoutType(workout.workoutType),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutFact extends StatelessWidget {
  const _WorkoutFact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SectionMessage extends StatelessWidget {
  const _SectionMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.neutral800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
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
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: const [
        _LoadingBlock(height: 28, width: 220),
        SizedBox(height: 12),
        _LoadingBlock(height: 18, width: 280),
        SizedBox(height: 28),
        _LoadingBlock(height: 104),
        SizedBox(height: 12),
        _LoadingBlock(height: 104),
        SizedBox(height: 28),
        _LoadingBlock(height: 160),
        SizedBox(height: 28),
        _LoadingBlock(height: 188),
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
          color: AppColors.neutral800,
          borderRadius: BorderRadius.circular(8),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  onRetry();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _workoutIcon(String workoutType) {
  switch (workoutType.trim().toLowerCase()) {
    case 'cardio':
      return Icons.monitor_heart_outlined;
    case 'strength':
      return Icons.fitness_center;
    case 'mobility':
      return Icons.accessibility_new_outlined;
    case 'recovery':
      return Icons.spa_outlined;
    default:
      return Icons.directions_run;
  }
}

String _formatWorkoutType(String workoutType) {
  final normalized = workoutType.trim();
  if (normalized.isEmpty) return 'Workout';

  final words = normalized.split(RegExp(r'[_\s]+'));
  return words
      .map(
        (word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}
