import 'package:fitness_application/core/network/api_client.dart';

import '../domain/logged_workout.dart';
import '../domain/workout_repository.dart';

class ApiWorkoutRepository implements WorkoutRepository {
  const ApiWorkoutRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ApiResult<LoggedWorkout>> logWorkout({
    required WorkoutDraft draft,
    required String idempotencyKey,
  }) {
    return _apiClient.post(
      '/v1/workouts',
      {
        'workout_type': draft.workoutType,
        'duration_minutes': draft.durationMinutes,
        if (draft.distanceKm != null) 'distance_km': draft.distanceKm,
        'logged_at': draft.loggedAt.toUtc().toIso8601String(),
      },
      (json) {
        final id = json['id'];
        final calories = json['calories'];
        final points = json['points_awarded'];
        final capped = json['capped'];
        if (id is! String ||
            calories is! int ||
            points is! int ||
            capped is! bool) {
          throw const FormatException('Invalid workout response');
        }
        return LoggedWorkout(
          id: id,
          calories: calories,
          pointsAwarded: points,
          capped: capped,
        );
      },
      extraHeaders: {'Idempotency-Key': idempotencyKey},
    );
  }
}
