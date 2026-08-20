import uuid
from collections.abc import Awaitable
from datetime import UTC, date, datetime, timedelta
from typing import Protocol

from fastapi import HTTPException
from sqlalchemy import func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import PointsTransaction, User, WorkoutLog
from app.features.workouts.domain import WorkoutType, calculate_workout_points
from app.features.workouts.schemas import LoggedWorkoutSchema, WorkoutCreate


class AsyncCache(Protocol):
    def delete(self, key: str) -> Awaitable[object]: ...


class WorkoutRepository(Protocol):
    async def log_workout(
        self, user: User, request: WorkoutCreate, idempotency_key: str
    ) -> LoggedWorkoutSchema: ...


def weekly_leaderboard_key(week_start: date) -> str:
    return f"leaderboard:weekly:{week_start.isoformat()}"


def week_start_for(logged_at: datetime) -> date:
    return (logged_at.astimezone(UTC) - timedelta(days=logged_at.weekday())).date()


def _calories_for(request: WorkoutCreate) -> int:
    multipliers = {
        WorkoutType.cardio: 7,
        WorkoutType.weight_lifting: 6,
        WorkoutType.yoga: 4,
    }
    return request.duration_minutes * multipliers[request.workout_type]


def _schema_from_log(workout: WorkoutLog) -> LoggedWorkoutSchema:
    return LoggedWorkoutSchema(
        id=workout.id,
        workout_type=workout.workout_type,
        duration_minutes=workout.duration_minutes,
        distance_km=workout.distance_km,
        logged_at=workout.logged_at,
        calories=workout.calories,
        points_awarded=workout.awarded_points,
        capped=workout.capped,
    )


class SqlAlchemyWorkoutRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def log_workout(
        self, user: User, request: WorkoutCreate, idempotency_key: str
    ) -> LoggedWorkoutSchema:
        day_start = datetime.combine(request.logged_at.date(), datetime.min.time(), tzinfo=UTC)
        day_end = day_start + timedelta(days=1)
        async with self._session.begin():
            locked_user = (
                await self._session.execute(select(User).where(User.id == user.id).with_for_update())
            ).scalar_one()
            points_awarded_today = (
                await self._session.scalar(
                    select(func.coalesce(func.sum(WorkoutLog.awarded_points), 0)).where(
                        WorkoutLog.user_id == locked_user.id,
                        WorkoutLog.logged_at >= day_start,
                        WorkoutLog.logged_at < day_end,
                    )
                )
            ) or 0
            award = calculate_workout_points(
                request.duration_minutes, request.workout_type, int(points_awarded_today)
            )
            workout = WorkoutLog(
                user_id=locked_user.id,
                workout_type=request.workout_type,
                duration_minutes=request.duration_minutes,
                distance_km=request.distance_km,
                logged_at=request.logged_at,
                calories=_calories_for(request),
                awarded_points=award.awarded,
                capped=award.capped,
                idempotency_key=idempotency_key,
            )
            try:
                async with self._session.begin_nested():
                    self._session.add(workout)
                    await self._session.flush()
            except IntegrityError as error:
                raise _idempotency_conflict() from error

            self._session.add(
                PointsTransaction(
                    user_id=locked_user.id,
                    source_type="workout",
                    source_reference=str(workout.id),
                    lifetime_delta=award.awarded,
                    available_delta=award.awarded,
                )
            )
            locked_user.lifetime_points += award.awarded
            locked_user.available_points += award.awarded
            locked_user.current_streak = await self._updated_streak(locked_user, request.logged_at)

        return _schema_from_log(workout)

    async def _updated_streak(self, user: User, logged_at: datetime) -> int:
        prior_logged_at = await self._session.scalar(
            select(WorkoutLog.logged_at)
            .where(WorkoutLog.user_id == user.id, WorkoutLog.logged_at < logged_at)
            .order_by(WorkoutLog.logged_at.desc())
            .limit(1)
        )
        if prior_logged_at is None:
            return 1
        previous_day = prior_logged_at.astimezone(UTC).date()
        logged_day = logged_at.astimezone(UTC).date()
        if previous_day == logged_day:
            return max(user.current_streak, 1)
        if previous_day == logged_day - timedelta(days=1):
            return max(user.current_streak, 1) + 1
        return 1


class InMemoryWorkoutRepository:
    """Explicit test seam that preserves the transactional service contract without PostgreSQL."""

    def __init__(self) -> None:
        self._keys: set[tuple[uuid.UUID, str]] = set()
        self._points_transactions: list[uuid.UUID] = []

    async def log_workout(
        self, user: User, request: WorkoutCreate, idempotency_key: str
    ) -> LoggedWorkoutSchema:
        key = (user.id, idempotency_key)
        if key in self._keys:
            raise _idempotency_conflict()
        award = calculate_workout_points(request.duration_minutes, request.workout_type, 0)
        workout = WorkoutLog(
            id=uuid.uuid4(),
            user_id=user.id,
            workout_type=request.workout_type,
            duration_minutes=request.duration_minutes,
            distance_km=request.distance_km,
            logged_at=request.logged_at,
            calories=_calories_for(request),
            awarded_points=award.awarded,
            capped=award.capped,
            idempotency_key=idempotency_key,
        )
        self._keys.add(key)
        self._points_transactions.append(user.id)
        user.lifetime_points += award.awarded
        user.available_points += award.awarded
        user.current_streak = max(user.current_streak, 1)
        return _schema_from_log(workout)

    def points_transaction_count(self, user_id: uuid.UUID) -> int:
        return self._points_transactions.count(user_id)


class WorkoutService:
    def __init__(self, workouts: WorkoutRepository, cache: AsyncCache) -> None:
        self._workouts = workouts
        self._cache = cache

    async def log_workout(
        self, user: User, request: WorkoutCreate, idempotency_key: str
    ) -> LoggedWorkoutSchema:
        result = await self._workouts.log_workout(user, request, idempotency_key)
        await self._cache.delete(weekly_leaderboard_key(week_start_for(request.logged_at)))
        return result


def _idempotency_conflict() -> HTTPException:
    return HTTPException(
        status_code=409,
        detail={
            "code": "IDEMPOTENCY_CONFLICT",
            "message": "This Idempotency-Key has already been used for this workout request.",
        },
    )
