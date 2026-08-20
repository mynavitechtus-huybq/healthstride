import uuid
from datetime import UTC, datetime, timedelta

import pytest

from app.db.models import User
from app.features.workouts.domain import WorkoutType
from app.features.workouts.schemas import WorkoutCreate
from app.features.workouts.service import InMemoryWorkoutRepository, WorkoutService, week_start_for


class FakeRedis:
    def __init__(self) -> None:
        self.values: dict[str, str] = {}

    async def delete(self, key: str) -> None:
        self.values.pop(key, None)

    async def get(self, key: str) -> str | None:
        return self.values.get(key)

    async def set(self, key: str, value: str, **_kwargs: object) -> bool:
        self.values[key] = value
        return True


@pytest.mark.anyio
async def test_workout_write_is_atomic_and_invalidates_weekly_leaderboard() -> None:
    user = User(
        id=uuid.uuid4(),
        firebase_uid="user-1",
        email="user@example.com",
        display_name="Ari",
        lifetime_points=0,
        available_points=0,
        current_streak=0,
    )
    redis = FakeRedis()
    repository = InMemoryWorkoutRepository()
    service = WorkoutService(repository, redis)
    request = WorkoutCreate(
        workout_type=WorkoutType.cardio,
        duration_minutes=30,
        distance_km=5,
        logged_at=datetime.now(UTC) - timedelta(minutes=1),
    )
    week_start = week_start_for(request.logged_at)
    await redis.set(f"leaderboard:weekly:{week_start.isoformat()}", '[{"rank": 1}]')

    result = await service.log_workout(user, request, "request-1")

    assert result.points_awarded == 150
    assert await redis.get(f"leaderboard:weekly:{week_start.isoformat()}") is None
    assert repository.points_transaction_count(user.id) == 1
    assert user.lifetime_points == 150


@pytest.mark.anyio
async def test_reusing_an_idempotency_key_does_not_award_points_twice() -> None:
    user = User(
        id=uuid.uuid4(),
        firebase_uid="user-1",
        email="user@example.com",
        display_name="Ari",
        lifetime_points=0,
        available_points=0,
        current_streak=0,
    )
    repository = InMemoryWorkoutRepository()
    service = WorkoutService(repository, FakeRedis())
    request = WorkoutCreate(
        workout_type=WorkoutType.yoga,
        duration_minutes=30,
        logged_at=datetime.now(UTC) - timedelta(minutes=1),
    )

    await service.log_workout(user, request, "request-1")
    with pytest.raises(Exception, match="IDEMPOTENCY_CONFLICT"):
        await service.log_workout(user, request, "request-1")

    assert repository.points_transaction_count(user.id) == 1
