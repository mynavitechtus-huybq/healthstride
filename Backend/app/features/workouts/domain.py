from dataclasses import dataclass
from enum import StrEnum


class WorkoutType(StrEnum):
    cardio = "cardio"
    weight_lifting = "weight_lifting"
    yoga = "yoga"


@dataclass(frozen=True)
class WorkoutPointsResult:
    awarded: int
    capped: bool


_POINTS_PER_MINUTE: dict[WorkoutType, int] = {
    WorkoutType.cardio: 5,
    WorkoutType.weight_lifting: 4,
    WorkoutType.yoga: 3,
}
_MINIMUM_POINTS_DURATION_MINUTES = 10
_MAX_POINTS_PER_WORKOUT = 300
_MAX_POINTS_PER_DAY = 500


def calculate_workout_points(
    duration_minutes: int,
    workout_type: WorkoutType,
    points_awarded_today: int,
) -> WorkoutPointsResult:
    """Calculate a provisional deterministic award while enforcing approved caps."""
    if duration_minutes < _MINIMUM_POINTS_DURATION_MINUTES:
        return WorkoutPointsResult(awarded=0, capped=False)

    uncapped_award = duration_minutes * _POINTS_PER_MINUTE[workout_type]
    workout_limited_award = min(uncapped_award, _MAX_POINTS_PER_WORKOUT)
    daily_remaining = max(_MAX_POINTS_PER_DAY - max(points_awarded_today, 0), 0)
    awarded = min(workout_limited_award, daily_remaining)
    return WorkoutPointsResult(awarded=awarded, capped=awarded < uncapped_award)
