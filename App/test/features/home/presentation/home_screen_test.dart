import 'package:fitness_application/core/network/api_client.dart';
import 'package:fitness_application/features/home/domain/home_dashboard.dart';
import 'package:fitness_application/features/home/domain/home_repository.dart';
import 'package:fitness_application/features/home/presentation/home_controller.dart';
import 'package:fitness_application/features/home/presentation/home_screen.dart';
import 'package:fitness_application/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders greeting, metrics, today plan, and popular workouts', (
    tester,
  ) async {
    final controller = HomeController(
      repository: _QueuedHomeRepository([
        ApiResult.success(_sampleDashboard()),
      ]),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _testApp(HomeScreen(controller: controller, onSignOut: () async {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back, Ari'), findsOneWidget);
    expect(find.text('120'), findsOneWidget);
    expect(find.text('Morning Cardio'), findsWidgets);
    expect(find.text('Popular Workouts'), findsOneWidget);
  });

  testWidgets('retries after an initial dashboard failure', (tester) async {
    final controller = HomeController(
      repository: _QueuedHomeRepository([
        const ApiResult.failure(
          ApiFailure(
            code: 'NETWORK_REQUEST_FAILED',
            message: 'Please try again.',
          ),
        ),
        ApiResult.success(_sampleDashboard(planName: 'Recovery Walk')),
      ]),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _testApp(HomeScreen(controller: controller, onSignOut: () async {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load your dashboard.'), findsOneWidget);
    expect(find.widgetWithIcon(FilledButton, Icons.refresh), findsOneWidget);

    await tester.tap(find.widgetWithIcon(FilledButton, Icons.refresh));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Recovery Walk'), findsWidgets);
  });

  testWidgets('shows an empty state when there is no plan for today', (
    tester,
  ) async {
    final controller = HomeController(
      repository: _QueuedHomeRepository([
        ApiResult.success(_sampleDashboard(hasTodayPlan: false)),
      ]),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _testApp(HomeScreen(controller: controller, onSignOut: () async {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('No plan for today yet.'), findsOneWidget);
  });

  testWidgets('keeps dashboard data visible when refresh fails', (
    tester,
  ) async {
    final controller = HomeController(
      repository: _QueuedHomeRepository([
        ApiResult.success(_sampleDashboard()),
        const ApiResult.failure(
          ApiFailure(
            code: 'NETWORK_REQUEST_FAILED',
            message: 'Please try again.',
          ),
        ),
      ]),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _testApp(HomeScreen(controller: controller, onSignOut: () async {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('Morning Cardio'), findsWidgets);

    await tester.drag(find.byType(ListView), const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Morning Cardio'), findsWidgets);
    expect(find.text('Unable to refresh your dashboard.'), findsOneWidget);
  });
}

Widget _testApp(Widget child) {
  return MaterialApp(theme: AppTheme.dark(), home: child);
}

class _QueuedHomeRepository implements HomeRepository {
  _QueuedHomeRepository(this._results);

  final List<ApiResult<HomeDashboard>> _results;
  var _index = 0;

  @override
  Future<ApiResult<HomeDashboard>> fetchDashboard() async {
    final index = _index;
    _index += 1;
    return _results[index];
  }
}

HomeDashboard _sampleDashboard({
  WorkoutSummary? todayPlan,
  bool hasTodayPlan = true,
  String planName = 'Morning Cardio',
}) {
  return HomeDashboard(
    profile: const HomeProfile(
      displayName: 'Ari',
      email: 'ari@example.com',
      lifetimePoints: 120,
      availablePoints: 90,
      currentStreak: 3,
    ),
    todayPlan: hasTodayPlan
        ? (todayPlan ??
              WorkoutSummary(
                slug: 'morning-cardio',
                name: planName,
                description: 'Start strong.',
                workoutType: 'cardio',
                durationMinutes: 30,
                estimatedCalories: 220,
                imageUrl: null,
              ))
        : null,
    popularWorkouts: const [
      WorkoutSummary(
        slug: 'core-blast',
        name: 'Core Blast',
        description: 'Build endurance.',
        workoutType: 'strength',
        durationMinutes: 20,
        estimatedCalories: 180,
        imageUrl: null,
      ),
    ],
  );
}
