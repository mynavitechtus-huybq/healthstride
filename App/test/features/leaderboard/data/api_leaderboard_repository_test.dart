import 'package:fitness_application/core/network/api_client.dart';
import 'package:fitness_application/features/leaderboard/data/api_leaderboard_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decodes weekly leaderboard rows and current user rank', () async {
    final repository = ApiLeaderboardRepository(
      ApiClient(
        tokenProvider: () async => 'firebase-token',
        getRequest: (_, {required headers}) async {
          expect(headers['Authorization'], 'Bearer firebase-token');
          return const ApiResponse(
            statusCode: 200,
            body: {
              'data': {
                'week_start': '2026-08-17',
                'current_user_rank': 2,
                'rows': [
                  {
                    'rank': 1,
                    'user_id': '00000000-0000-0000-0000-000000000001',
                    'display_name': 'Ari',
                    'points': 120,
                  },
                  {
                    'rank': 2,
                    'user_id': '00000000-0000-0000-0000-000000000002',
                    'display_name': 'Bao',
                    'points': 95,
                  },
                ],
              },
              'meta': {},
              'error': null,
            },
          );
        },
      ),
    );

    final result = await repository.fetchWeekly();

    expect(result.failure, isNull);
    expect(result.data?.weekStart, '2026-08-17');
    expect(result.data?.currentUserRank, 2);
    expect(result.data?.rows, hasLength(2));
    expect(result.data?.rows.first.displayName, 'Ari');
    expect(result.data?.rows.first.points, 120);
  });

  test('returns INVALID_RESPONSE for malformed leaderboard rows', () async {
    final repository = ApiLeaderboardRepository(
      ApiClient(
        tokenProvider: () async => null,
        getRequest: (_, {required headers}) async {
          return const ApiResponse(
            statusCode: 200,
            body: {
              'data': {
                'week_start': '2026-08-17',
                'current_user_rank': null,
                'rows': [
                  {
                    'rank': 'first',
                    'user_id': 'not-a-uuid',
                    'display_name': 'Ari',
                    'points': 120,
                  },
                ],
              },
              'meta': {},
              'error': null,
            },
          );
        },
      ),
    );

    final result = await repository.fetchWeekly();

    expect(result.data, isNull);
    expect(result.failure?.code, 'INVALID_RESPONSE');
  });
}
