import 'dart:async';

import 'package:fitness_application/core/network/api_client.dart';
import 'package:fitness_application/features/auth/domain/auth_repository.dart';
import 'package:fitness_application/features/auth/presentation/auth_gate.dart';
import 'package:fitness_application/features/home/domain/home_dashboard.dart';
import 'package:fitness_application/features/home/domain/home_repository.dart';
import 'package:fitness_application/features/home/presentation/home_controller.dart';
import 'package:fitness_application/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this._user);

  AuthUser? _user;
  final _controller = StreamController<AuthUser?>.broadcast();

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield _user;
    yield* _controller.stream;
  }

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async => null;

  @override
  Future<void> signInWithGoogle() async {
    _user = const AuthUser(
      id: 'user-1',
      displayName: 'Ari',
      email: 'ari@example.com',
    );
    _controller.add(_user);
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }
}

class FakeHomeRepository implements HomeRepository {
  FakeHomeRepository(this._result);

  final ApiResult<HomeDashboard> _result;

  @override
  Future<ApiResult<HomeDashboard>> fetchDashboard() async => _result;
}

void main() {
  testWidgets('shows Google sign-in when no Firebase user exists', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          repository: FakeAuthRepository(null),
          signedInBuilder: (context, user) => const Text('Signed in'),
        ),
      ),
    );

    await tester.pump();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Get Started'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Signed in'), findsNothing);
  });

  testWidgets('shows protected content when Firebase user exists', (
    tester,
  ) async {
    final repository = FakeAuthRepository(
      const AuthUser(
        id: 'user-1',
        displayName: 'Ari',
        email: 'ari@example.com',
      ),
    );
    final controller = HomeController(
      repository: FakeHomeRepository(
        ApiResult.success(
          HomeDashboard(
            profile: const HomeProfile(
              displayName: 'Ari',
              email: 'ari@example.com',
              lifetimePoints: 120,
              availablePoints: 90,
              currentStreak: 3,
            ),
            todayPlan: const WorkoutSummary(
              slug: 'morning-cardio',
              name: 'Morning Cardio',
              description: 'Start strong.',
              workoutType: 'cardio',
              durationMinutes: 30,
              estimatedCalories: 220,
              imageUrl: null,
            ),
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
          ),
        ),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: AuthGate(
          repository: repository,
          signedInBuilder: (_, user) =>
              HomeScreen(controller: controller, onSignOut: repository.signOut),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Good Morning 🔥'), findsOneWidget);
    expect(find.text('Hello Ari'), findsNothing);
    expect(find.text('Continue with Google'), findsNothing);

    await tester.tap(find.byTooltip('Sign out'));
    await tester.pump();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Get Started'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
