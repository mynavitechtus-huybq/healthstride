import asyncio

import pytest

from app.core.rate_limit import SlidingWindowLimiter


class FakeRedis:
    def __init__(self) -> None:
        self.values: dict[str, dict[str, float]] = {}

    async def eval(self, _script: str, _numkeys: int, key: str, *args: object) -> int:
        now = float(args[0])
        window_seconds = int(args[1])
        limit = int(args[2])
        member = str(args[3])
        entries = self.values.setdefault(key, {})
        self.values[key] = {
            score_key: score for score_key, score in entries.items() if score > now - window_seconds
        }
        if len(self.values[key]) >= limit:
            return 0
        self.values[key][member] = now
        return 1


@pytest.mark.anyio
async def test_rate_limit_rejects_the_next_post_within_the_window() -> None:
    limiter = SlidingWindowLimiter(FakeRedis(), now=lambda: 1_000.0)

    for _ in range(10):
        assert (await limiter.allow("user-1:POST", 10, 60)).allowed

    assert (await limiter.allow("user-1:POST", 10, 60)).allowed is False


@pytest.mark.anyio
async def test_rate_limit_allows_requests_after_the_window_expires() -> None:
    current_time = [1_000.0]
    limiter = SlidingWindowLimiter(FakeRedis(), now=lambda: current_time[0])

    assert (await limiter.allow("user-1:GET", 1, 60)).allowed
    current_time[0] += 61

    assert (await limiter.allow("user-1:GET", 1, 60)).allowed


@pytest.mark.anyio
async def test_concurrent_requests_never_exceed_the_limit() -> None:
    limiter = SlidingWindowLimiter(FakeRedis(), now=lambda: 1_000.0)

    decisions = await asyncio.gather(*(limiter.allow("user-1:POST", 10, 60) for _ in range(100)))

    assert sum(decision.allowed for decision in decisions) == 10
