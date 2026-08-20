from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from typing import cast

import redis.asyncio as redis_asyncio
from fastapi import FastAPI, Request

from app.core.config import settings


@asynccontextmanager
async def redis_lifespan(app: FastAPI) -> AsyncIterator[None]:
    if not settings.redis_url:
        yield
        return

    client = redis_asyncio.from_url(settings.redis_url, decode_responses=True)
    app.state.redis = client
    try:
        yield
    finally:
        await client.aclose()
        app.state.redis = None


def get_redis_client(request: Request) -> redis_asyncio.Redis:
    client = getattr(request.app.state, "redis", None)
    if client is None:
        raise RuntimeError("REDIS_URL must be configured before accessing Redis.")
    return cast(redis_asyncio.Redis, client)
