import 'package:fitness_application/core/network/api_client.dart';
import 'package:fitness_application/features/home/data/api_home_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decodes the complete home payload', () async {
    final repository = ApiHomeRepository(
      ApiClient(
        tokenProvider: () async => null,
        getRequest: (_, {required headers}) async {
          expect(headers['Accept'], 'application/json');
          return const ApiResponse(
            statusCode: 200,
            body: {
              'data': {
                'profile': {
                  'display_name': 'Ari',
                  'email': 'ari@example.com',
                  'lifetime_points': 120,
                  'available_points': 90,
                  'current_streak': 3,
                },
                'today_plan': {
                  'slug': 'morning-cardio',
                  'name': 'Morning Cardio',
                  'description': 'Start strong.',
                  'workout_type': 'cardio',
                  'duration_minutes': 30,
                  'estimated_calories': 220,
                  'image_url': null,
                },
                'popular_workouts': [
                  {
                    'slug': 'core-blast',
                    'name': 'Core Blast',
                    'description': 'Build endurance.',
                    'workout_type': 'strength',
                    'duration_minutes': 20,
                    'estimated_calories': 180,
                    'image_url': null,
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

    final result = await repository.fetchDashboard();

    expect(result.failure, isNull);
    expect(result.data?.profile.currentStreak, 3);
    expect(result.data?.profile.availablePoints, 90);
    expect(result.data?.todayPlan?.slug, 'morning-cardio');
    expect(result.data?.popularWorkouts.single.name, 'Core Blast');
  });

  test('accepts a null today_plan', () async {
    final repository = ApiHomeRepository(
      ApiClient(
        tokenProvider: () async => null,
        getRequest: (_, {required headers}) async {
          return const ApiResponse(
            statusCode: 200,
            body: {
              'data': {
                'profile': {
                  'display_name': 'Ari',
                  'email': 'ari@example.com',
                  'lifetime_points': 120,
                  'available_points': 90,
                  'current_streak': 3,
                },
                'today_plan': null,
                'popular_workouts': [],
              },
              'meta': {},
              'error': null,
            },
          );
        },
      ),
    );

    final result = await repository.fetchDashboard();

    expect(result.failure, isNull);
    expect(result.data?.todayPlan, isNull);
    expect(result.data?.popularWorkouts, isEmpty);
  });

  test(
    'returns INVALID_RESPONSE when a required field has the wrong type',
    () async {
      final repository = ApiHomeRepository(
        ApiClient(
          tokenProvider: () async => null,
          getRequest: (_, {required headers}) async {
            return const ApiResponse(
              statusCode: 200,
              body: {
                'data': {
                  'profile': {
                    'display_name': 'Ari',
                    'email': 'ari@example.com',
                    'lifetime_points': 120,
                    'available_points': 90,
                    'current_streak': 'three',
                  },
                  'today_plan': null,
                  'popular_workouts': [],
                },
                'meta': {},
                'error': null,
              },
            );
          },
        ),
      );

      final result = await repository.fetchDashboard();

      expect(result.data, isNull);
      expect(result.failure?.code, 'INVALID_RESPONSE');
      expect(result.failure?.message, 'Invalid API response.');
    },
  );

  test('preserves transport failures from ApiClient', () async {
    final repository = ApiHomeRepository(
      ApiClient(
        tokenProvider: () async => null,
        getRequest: (_, {required headers}) async {
          return const ApiResponse(
            statusCode: 503,
            body: {
              'data': null,
              'meta': null,
              'error': {
                'code': 'NETWORK_REQUEST_FAILED',
                'message': 'Please try again.',
              },
            },
          );
        },
      ),
    );

    final result = await repository.fetchDashboard();

    expect(result.data, isNull);
    expect(result.failure?.code, 'NETWORK_REQUEST_FAILED');
  });
}
