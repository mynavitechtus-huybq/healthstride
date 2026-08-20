import 'dart:async';

import 'package:fitness_application/core/network/api_client.dart';
import 'package:fitness_application/features/home/domain/home_dashboard.dart';
import 'package:fitness_application/features/home/domain/home_repository.dart';
import 'package:fitness_application/features/home/presentation/home_controller.dart';
import 'package:fitness_application/features/home/presentation/home_screen.dart';
import 'package:fitness_application/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the Figma home composition and filters workouts', (
    tester,
  ) async {
    final controller = HomeController(
      repository: _QueuedHomeRepository([
        ApiResult.success(
          _sampleDashboard(
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
              WorkoutSummary(
                slug: 'hand-training',
                name: 'Hand Training',
                description: 'Build upper body strength.',
                workoutType: 'strength',
                durationMinutes: 40,
                estimatedCalories: 600,
                imageUrl: null,
              ),
            ],
          ),
        ),
      ]),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _testApp(HomeScreen(controller: controller, onSignOut: () async {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('Good Morning 🔥'), findsOneWidget);
    expect(find.text('Ari'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-search-field')), findsOneWidget);
    expect(find.text('Popular Workouts'), findsOneWidget);
    expect(find.text('Core Blast'), findsOneWidget);
    expect(find.text('Today Plan'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.byTooltip('Explore'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('home-search-field')),
      'Hand',
    );
    await tester.pump();

    expect(find.text('Hand Training'), findsOneWidget);
    expect(find.text('Core Blast'), findsNothing);
  });

  testWidgets('renders greeting, today plan, and popular workouts', (
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

    expect(find.text('Good Morning 🔥'), findsOneWidget);
    expect(find.text('Ari'), findsOneWidget);
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
    expect(
      find.widgetWithIcon(FilledButton, Icons.refresh_rounded),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithIcon(FilledButton, Icons.refresh_rounded));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Recovery Walk'), findsWidgets);
  });

  testWidgets('renders the initial loading placeholder while pending', (
    tester,
  ) async {
    final completer = Completer<ApiResult<HomeDashboard>>();
    final controller = HomeController(
      repository: _DeferredHomeRepository(completer.future),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _testApp(HomeScreen(controller: controller, onSignOut: () async {})),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('home-loading-view')), findsOneWidget);
    expect(find.text('Good Morning 🔥'), findsNothing);
    expect(find.text('Unable to load your dashboard.'), findsNothing);

    completer.complete(ApiResult.success(_sampleDashboard()));
    await tester.pumpAndSettle();
  });

  testWidgets('shows fallback plans when there is no plan for today', (
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

    await tester.drag(
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(find.text('Push Up'), findsOneWidget);
    expect(find.text('Sit Up'), findsOneWidget);
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

    await tester.drag(find.byType(ListView).first, const Offset(0, 300));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('Morning Cardio'), findsWidgets);
    expect(find.text('Unable to refresh your dashboard.'), findsOneWidget);
  });

  testWidgets('renders the branded dashboard at a 390x844 phone size', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final controller = HomeController(
      repository: _QueuedHomeRepository([
        ApiResult.success(_sampleDashboard(displayName: '  ', email: '  ')),
      ]),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _testApp(HomeScreen(controller: controller, onSignOut: () async {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('Good Morning 🔥'), findsOneWidget);
    expect(find.text('Athlete'), findsOneWidget);
    expect(tester.takeException(), isNull);
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

class _DeferredHomeRepository implements HomeRepository {
  _DeferredHomeRepository(this._result);

  final Future<ApiResult<HomeDashboard>> _result;

  @override
  Future<ApiResult<HomeDashboard>> fetchDashboard() => _result;
}

HomeDashboard _sampleDashboard({
  WorkoutSummary? todayPlan,
  bool hasTodayPlan = true,
  String planName = 'Morning Cardio',
  String displayName = 'Ari',
  String email = 'ari@example.com',
  List<WorkoutSummary>? popularWorkouts,
}) {
  return HomeDashboard(
    profile: HomeProfile(
      displayName: displayName,
      email: email,
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
    popularWorkouts:
        popularWorkouts ??
        const [
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
