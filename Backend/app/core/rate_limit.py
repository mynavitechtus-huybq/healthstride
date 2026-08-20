from collections.abc import Awaitable, Callable
from dataclasses import dataclass
from time import time
from typing import Protocol
from uuid import uuid4


class SlidingWindowRedis(Protocol):
    def eval(self, script: str, numkeys: int, *keys_and_args: object) -> Awaitable[int]: ...


@dataclass(frozen=True)
class RateLimitDecision:
    allowed: bool


class SlidingWindowLimiter:
    """Redis sorted-set limiter whose key contains a verified user identifier."""

    def __init__(self, redis: SlidingWindowRedis, now: Callable[[], float] = time) -> None:
        self._redis = redis
        self._now = now

    async def allow(self, key: str, limit: int, window_seconds: int) -> RateLimitDecision:
        current_time = self._now()
        allowed = await self._redis.eval(
            """
            redis.call('ZREMRANGEBYSCORE', KEYS[1], '-inf', ARGV[1] - ARGV[2])
            if redis.call('ZCARD', KEYS[1]) >= tonumber(ARGV[3]) then
                redis.call('EXPIRE', KEYS[1], ARGV[2])
                return 0
            end
            redis.call('ZADD', KEYS[1], ARGV[1], ARGV[4])
            redis.call('EXPIRE', KEYS[1], ARGV[2])
            return 1
            """,
            1,
            key,
            current_time,
            window_seconds,
            limit,
            f"{current_time}:{uuid4()}",
        )
        return RateLimitDecision(allowed=bool(allowed))
