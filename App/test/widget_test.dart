import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_application/core/network/api_client.dart';
import 'package:fitness_application/features/auth/domain/auth_repository.dart';
import 'package:fitness_application/features/home/domain/home_dashboard.dart';
import 'package:fitness_application/features/home/domain/home_repository.dart';
import 'package:fitness_application/main.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this._user);

  final AuthUser? _user;

  @override
  Stream<AuthUser?> authStateChanges() => Stream.value(_user);

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async => null;

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}
}

class _StableAuthRepository implements AuthRepository {
  _StableAuthRepository(AuthUser? user)
    : _stream = Stream<AuthUser?>.multi((controller) {
        controller.add(user);
      }, isBroadcast: true);

  final Stream<AuthUser?> _stream;

  @override
  Stream<AuthUser?> authStateChanges() => _stream;

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async => null;

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signOut() async {}
}

class _FakeHomeRepository implements HomeRepository {
  const _FakeHomeRepository(this._result);

  final ApiResult<HomeDashboard> _result;

  @override
  Future<ApiResult<HomeDashboard>> fetchDashboard() async => _result;
}

void main() {
  testWidgets(
    'shows the authenticated dashboard instead of the legacy greeting',
    (tester) async {
      await tester.pumpWidget(
        MyApp(
          authRepository: _FakeAuthRepository(
            const AuthUser(
              id: 'user-1',
              email: 'ari@example.com',
              displayName: 'Ari',
            ),
          ),
          homeRepository: _FakeHomeRepository(
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
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Welcome back, Ari'), findsOneWidget);
      expect(find.text('Hello Ari'), findsNothing);
      final context = tester.element(find.text('Welcome back, Ari'));
      expect(Theme.of(context).colorScheme.primary, const Color(0xFFBBF246));
      expect(
        Theme.of(context).scaffoldBackgroundColor,
        const Color(0xFF192126),
      );
    },
  );

  testWidgets(
    'reloads the authenticated dashboard when homeRepository changes for the same user',
    (tester) async {
      final authRepository = _StableAuthRepository(
        const AuthUser(
          id: 'user-1',
          email: 'ari@example.com',
          displayName: 'Ari',
        ),
      );

      await tester.pumpWidget(
        MyApp(
          authRepository: authRepository,
          homeRepository: _FakeHomeRepository(
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
                popularWorkouts: const [],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Morning Cardio'), findsWidgets);
      expect(find.text('Recovery Walk'), findsNothing);

      await tester.pumpWidget(
        MyApp(
          authRepository: authRepository,
          homeRepository: _FakeHomeRepository(
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
                  slug: 'recovery-walk',
                  name: 'Recovery Walk',
                  description: 'Reset for tomorrow.',
                  workoutType: 'recovery',
                  durationMinutes: 25,
                  estimatedCalories: 140,
                  imageUrl: null,
                ),
                popularWorkouts: const [],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Recovery Walk'), findsWidgets);
      expect(find.text('Morning Cardio'), findsNothing);
    },
  );
}
