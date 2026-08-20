from app.features.workouts.domain import (
    WorkoutType,
    calculate_workout_points,
)


def test_short_workout_is_saved_with_no_points() -> None:
    result = calculate_workout_points(9, WorkoutType.cardio, 0)

    assert result.awarded == 0
    assert result.capped is False


def test_workout_and_daily_caps_are_applied() -> None:
    result = calculate_workout_points(180, WorkoutType.weight_lifting, 450)

    assert result.awarded == 50
    assert result.capped is True
