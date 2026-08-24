import 'package:fitness_application/core/network/api_client.dart';
import 'package:flutter/foundation.dart';

import '../domain/logged_workout.dart';
import '../domain/workout_repository.dart';

class LogWorkoutController extends ValueNotifier<LogWorkoutState> {
  LogWorkoutController({required this.repository})
    : super(const LogWorkoutState());

  final WorkoutRepository repository;

  Future<void> submit(WorkoutDraft draft) async {
    if (value.isSubmitting) return;
    value = const LogWorkoutState(isSubmitting: true);
    late final ApiResult<LoggedWorkout> result;
    try {
      result = await repository.logWorkout(
        draft: draft,
        idempotencyKey: DateTime.now().microsecondsSinceEpoch.toString(),
      );
    } catch (_) {
      value = const LogWorkoutState(
        failure: ApiFailure(
          code: 'WORKOUT_SUBMIT_FAILED',
          message: 'Could not save workout. Please try again.',
        ),
      );
      return;
    }
    value = result.data == null
        ? LogWorkoutState(failure: result.failure)
        : LogWorkoutState(workout: result.data);
  }
}

class LogWorkoutState {
  const LogWorkoutState({
    this.workout,
    this.failure,
    this.isSubmitting = false,
  });

  final LoggedWorkout? workout;
  final ApiFailure? failure;
  final bool isSubmitting;
}
