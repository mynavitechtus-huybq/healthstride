import 'package:fitness_application/core/network/api_client.dart';
import 'package:fitness_application/features/leaderboard/domain/leaderboard_repository.dart';
import 'package:fitness_application/features/leaderboard/domain/weekly_leaderboard.dart';
import 'package:fitness_application/features/leaderboard/presentation/leaderboard_controller.dart';
import 'package:fitness_application/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:fitness_application/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders rank summary and weekly rows', (tester) async {
    final controller = LeaderboardController(
      repository: _FakeLeaderboardRepository(
        const ApiResult.success(
          WeeklyLeaderboard(
            weekStart: '2026-08-17',
            currentUserRank: 2,
            rows: [
              LeaderboardRow(
                rank: 1,
                userId: 'user-1',
                displayName: 'Ari',
                points: 120,
              ),
              LeaderboardRow(
                rank: 2,
                userId: 'user-2',
                displayName: 'Bao',
                points: 95,
              ),
            ],
          ),
        ),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: LeaderboardScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your weekly rank'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);
    expect(find.text('Ari'), findsOneWidget);
    expect(find.text('120 pts'), findsOneWidget);
  });

  testWidgets('renders retry state when API fails', (tester) async {
    final controller = LeaderboardController(
      repository: _FakeLeaderboardRepository(
        const ApiResult.failure(
          ApiFailure(
            code: 'NETWORK_REQUEST_FAILED',
            message: 'Try again.',
          ),
        ),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: LeaderboardScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unable to load leaderboard.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}

class _FakeLeaderboardRepository implements LeaderboardRepository {
  const _FakeLeaderboardRepository(this.result);

  final ApiResult<WeeklyLeaderboard> result;

  @override
  Future<ApiResult<WeeklyLeaderboard>> fetchWeekly() async => result;
}
