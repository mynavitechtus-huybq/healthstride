import asyncio
import json
from collections.abc import Awaitable, Callable
from datetime import UTC, date, datetime, timedelta
from typing import Protocol
from uuid import UUID, uuid4

from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import User, WorkoutLog
from app.features.workouts.schemas import LeaderboardRowSchema, WeeklyLeaderboardSchema
from app.features.workouts.service import weekly_leaderboard_key

_CACHE_TTL_SECONDS = 60
_LOCK_TTL_SECONDS = 1
_POLL_INTERVAL_SECONDS = 0.05
_POLL_ATTEMPTS = 20


class LeaderboardCache(Protocol):
    def get(self, key: str) -> Awaitable[str | bytes | None]: ...

    def set(self, key: str, value: str, **kwargs: object) -> Awaitable[bool | str | bytes | None]: ...

    def delete(self, key: str) -> Awaitable[object]: ...

    def eval(self, script: str, numkeys: int, *keys_and_args: object) -> Awaitable[int]: ...


class LeaderboardRepository(Protocol):
    async def weekly_rows(self, week_start: date) -> list[LeaderboardRowSchema]: ...

    async def current_user_rank(self, user_id: UUID, week_start: date) -> int | None: ...


def weekly_leaderboard_lock_key(week_start: date) -> str:
    return f"{weekly_leaderboard_key(week_start)}:lock"


def _week_start(now: datetime) -> date:
    current = now.astimezone(UTC)
    return (current - timedelta(days=current.weekday())).date()


class SqlAlchemyLeaderboardRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def weekly_rows(self, week_start: date) -> list[LeaderboardRowSchema]:
        week_start_datetime = datetime.combine(week_start, datetime.min.time(), tzinfo=UTC)
        week_end_datetime = week_start_datetime + timedelta(days=7)
        score = func.coalesce(func.sum(WorkoutLog.awarded_points), 0).label("points")
        statement = (
            select(User.id, User.display_name, score)
            .join(WorkoutLog, WorkoutLog.user_id == User.id)
            .where(WorkoutLog.logged_at >= week_start_datetime, WorkoutLog.logged_at < week_end_datetime)
            .group_by(User.id, User.display_name)
            .order_by(score.desc(), User.id)
            .limit(50)
        )
        rows = (await self._session.execute(statement)).all()
        return [
            LeaderboardRowSchema(rank=index, user_id=row.id, display_name=row.display_name, points=int(row.points))
            for index, row in enumerate(rows, start=1)
        ]

    async def current_user_rank(self, user_id: UUID, week_start: date) -> int | None:
        week_start_datetime = datetime.combine(week_start, datetime.min.time(), tzinfo=UTC)
        week_end_datetime = week_start_datetime + timedelta(days=7)
        score = func.coalesce(func.sum(WorkoutLog.awarded_points), 0).label("points")
        ranked_rows = (
            select(
                User.id.label("user_id"),
                func.row_number().over(order_by=(score.desc(), User.id)).label("rank"),
            )
            .join(WorkoutLog, WorkoutLog.user_id == User.id)
            .where(WorkoutLog.logged_at >= week_start_datetime, WorkoutLog.logged_at < week_end_datetime)
            .group_by(User.id)
            .subquery()
        )
        rank = await self._session.scalar(
            select(ranked_rows.c.rank).where(ranked_rows.c.user_id == user_id)
        )
        return int(rank) if rank is not None else None


class InMemoryLeaderboardRepository:
    def __init__(
        self, rows: list[LeaderboardRowSchema], current_user_ranks: dict[UUID, int] | None = None
    ) -> None:
        self._rows = rows
        self._current_user_ranks = current_user_ranks or {}
        self.query_count = 0
        self.rank_query_count = 0

    async def weekly_rows(self, _week_start: date) -> list[LeaderboardRowSchema]:
        self.query_count += 1
        return self._rows

    async def current_user_rank(self, user_id: UUID, _week_start: date) -> int | None:
        self.rank_query_count += 1
        return self._current_user_ranks.get(
            user_id, next((row.rank for row in self._rows if row.user_id == user_id), None)
        )


class LeaderboardService:
    def __init__(
        self,
        repository: LeaderboardRepository,
        cache: LeaderboardCache,
        sleep: Callable[[float], Awaitable[None]] = asyncio.sleep,
    ) -> None:
        self._repository = repository
        self._cache = cache
        self._sleep = sleep

    async def get_weekly(
        self, user: User, now: datetime | None = None
    ) -> WeeklyLeaderboardSchema:
        week_start = _week_start(now or datetime.now(UTC))
        key = weekly_leaderboard_key(week_start)
        cached = await self._read_cached(key)
        if cached is None:
            cached = await self._load_with_lock(week_start, key)
        return WeeklyLeaderboardSchema(
            week_start=week_start.isoformat(),
            rows=cached,
            current_user_rank=await self._repository.current_user_rank(user.id, week_start),
        )

    async def _read_cached(self, key: str) -> list[LeaderboardRowSchema] | None:
        value = await self._cache.get(key)
        if value is None:
            return None
        if isinstance(value, bytes):
            value = value.decode()
        return [LeaderboardRowSchema.model_validate(row) for row in json.loads(value)]

    async def _load_with_lock(self, week_start: date, key: str) -> list[LeaderboardRowSchema]:
        lock_key = weekly_leaderboard_lock_key(week_start)
        lock_token = uuid4().hex
        if await self._cache.set(lock_key, lock_token, nx=True, ex=_LOCK_TTL_SECONDS):
            try:
                return await self._query_and_cache(week_start, key)
            finally:
                await self._release_lock(lock_key, lock_token)

        for _ in range(_POLL_ATTEMPTS):
            await self._sleep(_POLL_INTERVAL_SECONDS)
            cached = await self._read_cached(key)
            if cached is not None:
                return cached

        # The lock's bounded expiry has elapsed. A second owner may now query and refill the cache.
        lock_token = uuid4().hex
        if await self._cache.set(lock_key, lock_token, nx=True, ex=_LOCK_TTL_SECONDS):
            try:
                return await self._query_and_cache(week_start, key)
            finally:
                await self._release_lock(lock_key, lock_token)
        return await self._load_with_lock(week_start, key)

    async def _release_lock(self, lock_key: str, lock_token: str) -> None:
        await self._cache.eval(
            """
            if redis.call('GET', KEYS[1]) == ARGV[1] then
                return redis.call('DEL', KEYS[1])
            end
            return 0
            """,
            1,
            lock_key,
            lock_token,
        )

    async def _query_and_cache(self, week_start: date, key: str) -> list[LeaderboardRowSchema]:
        rows = await self._repository.weekly_rows(week_start)
        await self._cache.set(
            key,
            json.dumps([row.model_dump(mode="json") for row in rows]),
            ex=_CACHE_TTL_SECONDS,
        )
        return rows
