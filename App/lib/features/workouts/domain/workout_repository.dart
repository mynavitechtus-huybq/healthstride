import 'package:fitness_application/core/network/api_client.dart';

import 'logged_workout.dart';

abstract interface class WorkoutRepository {
  Future<ApiResult<LoggedWorkout>> logWorkout({
    required WorkoutDraft draft,
    required String idempotencyKey,
  });
}

class WorkoutDraft {
  const WorkoutDraft({
    required this.workoutType,
    required this.durationMinutes,
    required this.loggedAt,
    this.distanceKm,
  });

  final String workoutType;
  final int durationMinutes;
  final double? distanceKm;
  final DateTime loggedAt;
}
