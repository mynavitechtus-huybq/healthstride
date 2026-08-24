import 'package:fitness_application/core/network/api_client.dart';
import 'package:fitness_application/features/workouts/domain/logged_workout.dart';
import 'package:fitness_application/features/workouts/domain/workout_repository.dart';
import 'package:fitness_application/features/workouts/presentation/log_workout_controller.dart';
import 'package:fitness_application/features/workouts/presentation/log_workout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('validates and submits a cardio workout', (tester) async {
    final repository = _FakeWorkoutRepository();
    final controller = LogWorkoutController(repository: repository);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LogWorkoutScreen(controller: controller)),
    );

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cardio').last);
    await tester.pump();
    await tester.enterText(find.byType(TextFormField).at(0), '30');
    await tester.enterText(find.byType(TextFormField).at(1), '4.5');
    await tester.tap(find.text('Save workout'));
    await tester.pumpAndSettle();

    expect(repository.lastDraft?.workoutType, 'cardio');
    expect(repository.lastDraft?.durationMinutes, 30);
    expect(repository.lastDraft?.distanceKm, 4.5);
    expect(find.text('Workout saved: +20 points'), findsOneWidget);
  });

  testWidgets('does not submit an invalid duration', (tester) async {
    final repository = _FakeWorkoutRepository();
    final controller = LogWorkoutController(repository: repository);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: LogWorkoutScreen(controller: controller)),
    );
    await tester.enterText(find.byType(TextFormField).first, '0');
    await tester.tap(find.text('Save workout'));
    await tester.pump();

    expect(find.text('Enter a positive duration.'), findsOneWidget);
    expect(repository.lastDraft, isNull);
  });
}

class _FakeWorkoutRepository implements WorkoutRepository {
  WorkoutDraft? lastDraft;

  @override
  Future<ApiResult<LoggedWorkout>> logWorkout({
    required WorkoutDraft draft,
    required String idempotencyKey,
  }) async {
    lastDraft = draft;
    return const ApiResult.success(
      LoggedWorkout(
        id: 'workout-1',
        calories: 240,
        pointsAwarded: 20,
        capped: false,
      ),
    );
  }
}
