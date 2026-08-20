import asyncio
import json
import uuid
from datetime import UTC, date, datetime, timedelta

import pytest

from app.db.models import User
from app.features.leaderboard.service import (
    InMemoryLeaderboardRepository,
    LeaderboardRowSchema,
    LeaderboardService,
    weekly_leaderboard_lock_key,
)


class FakeRedis:
    def __init__(self) -> None:
        self.values: dict[str, str] = {}

    async def get(self, key: str) -> str | None:
        return self.values.get(key)

    async def set(self, key: str, value: str, **kwargs: object) -> bool | None:
        if kwargs.get("nx") and key in self.values:
            return None
        self.values[key] = value
        return True

    async def delete(self, key: str) -> None:
        self.values.pop(key, None)

    async def eval(self, _script: str, _numkeys: int, key: str, token: str) -> int:
        if self.values.get(key) == token:
            self.values.pop(key, None)
            return 1
        return 0


@pytest.mark.anyio
async def test_weekly_leaderboard_reads_cached_rows_before_querying_database() -> None:
    user = User(
        id=uuid.uuid4(), firebase_uid="user-1", email="u@example.com", display_name="Ari"
    )
    redis = FakeRedis()
    repository = InMemoryLeaderboardRepository([])
    service = LeaderboardService(repository, redis, sleep=lambda _seconds: _no_wait())
    now = datetime.now(UTC)
    week_start = (now - timedelta(days=now.weekday())).date()
    await redis.set(
        f"leaderboard:weekly:{week_start.isoformat()}",
        json.dumps([{"rank": 1, "user_id": str(user.id), "display_name": "Ari", "points": 90}]),
    )

    result = await service.get_weekly(user, now=now)

    assert result.rows[0].points == 90
    assert repository.query_count == 0


async def _no_wait() -> None:
    return None


class SlowRepository:
    def __init__(self) -> None:
        self.started: list[asyncio.Event] = [asyncio.Event(), asyncio.Event()]
        self.release: list[asyncio.Event] = [asyncio.Event(), asyncio.Event()]
        self.query_count = 0

    async def weekly_rows(self, _week_start: date) -> list[LeaderboardRowSchema]:
        query_index = self.query_count
        self.query_count += 1
        self.started[query_index].set()
        await self.release[query_index].wait()
        return []

    async def current_user_rank(self, _user_id: uuid.UUID, _week_start: date) -> int | None:
        return None


class ExpiringLockRedis(FakeRedis):
    def expire_lock(self, key: str) -> None:
        self.values.pop(key, None)


@pytest.mark.anyio
async def test_expired_lock_owner_cannot_delete_a_later_owners_lock() -> None:
    user = User(id=uuid.uuid4(), firebase_uid="user-1", email="u@example.com", display_name="Ari")
    redis = ExpiringLockRedis()
    repository = SlowRepository()
    service = LeaderboardService(repository, redis, sleep=lambda _seconds: _no_wait())
    now = datetime.now(UTC)
    lock_key = weekly_leaderboard_lock_key((now - timedelta(days=now.weekday())).date())

    first = asyncio.create_task(service.get_weekly(user, now=now))
    await repository.started[0].wait()
    redis.expire_lock(lock_key)
    second = asyncio.create_task(service.get_weekly(user, now=now))
    await repository.started[1].wait()

    repository.release[0].set()
    await first

    assert lock_key in redis.values
    repository.release[1].set()
    await second


@pytest.mark.anyio
async def test_cached_top_fifty_uses_repository_for_current_users_rank() -> None:
    user = User(id=uuid.uuid4(), firebase_uid="user-51", email="u@example.com", display_name="Ari")
    rows = [
        LeaderboardRowSchema(rank=index, user_id=uuid.uuid4(), display_name=str(index), points=100 - index)
        for index in range(1, 51)
    ]
    redis = FakeRedis()
    repository = InMemoryLeaderboardRepository(rows, current_user_ranks={user.id: 51})
    service = LeaderboardService(repository, redis, sleep=lambda _seconds: _no_wait())
    now = datetime.now(UTC)
    await redis.set(
        f"leaderboard:weekly:{(now - timedelta(days=now.weekday())).date().isoformat()}",
        json.dumps([row.model_dump(mode="json") for row in rows]),
    )

    result = await service.get_weekly(user, now=now)

    assert result.current_user_rank == 51
    assert repository.rank_query_count == 1
