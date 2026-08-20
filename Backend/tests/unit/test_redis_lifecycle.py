import pytest
import redis.asyncio as redis_asyncio

from app.core.config import settings
from app.main import app


class TrackingRedis:
    def __init__(self) -> None:
        self.closed = False

    async def aclose(self) -> None:
        self.closed = True


@pytest.mark.anyio
async def test_application_lifespan_reuses_and_closes_async_redis_client(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    client = TrackingRedis()
    created: list[TrackingRedis] = []

    def create_client(*_args: object, **_kwargs: object) -> TrackingRedis:
        created.append(client)
        return client

    monkeypatch.setattr(settings, "redis_url", "redis://test")
    monkeypatch.setattr(redis_asyncio, "from_url", create_client)

    async with app.router.lifespan_context(app):
        first = app.state.redis
        second = app.state.redis

        assert first is second

    assert created == [client]
    assert client.closed
