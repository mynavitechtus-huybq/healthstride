from typing import Annotated

import redis.asyncio as redis_asyncio
from fastapi import APIRouter, Depends, Header, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.api_envelope import ErrorEnvelope, SuccessEnvelope, success
from app.core.rate_limit import SlidingWindowLimiter, SlidingWindowRedis
from app.core.redis import get_redis_client
from app.db.models import User
from app.db.session import get_session
from app.features.auth.dependencies import get_current_user
from app.features.workouts.schemas import LoggedWorkoutSchema, WorkoutCreate
from app.features.workouts.service import SqlAlchemyWorkoutRepository, WorkoutService

router = APIRouter(tags=["workouts"])


def get_rate_limiter(
    redis: Annotated[SlidingWindowRedis, Depends(get_redis_client)],
) -> SlidingWindowLimiter:
    return SlidingWindowLimiter(redis)


def get_workout_service(
    session: Annotated[AsyncSession, Depends(get_session)],
    cache: Annotated[redis_asyncio.Redis, Depends(get_redis_client)],
) -> WorkoutService:
    return WorkoutService(SqlAlchemyWorkoutRepository(session), cache)


@router.post(
    "/workouts",
    response_model=SuccessEnvelope[LoggedWorkoutSchema],
    responses={
        401: {"model": ErrorEnvelope},
        409: {"model": ErrorEnvelope},
        422: {"model": ErrorEnvelope},
        429: {"model": ErrorEnvelope},
    },
)
async def create_workout(
    payload: WorkoutCreate,
    current_user: Annotated[User, Depends(get_current_user)],
    idempotency_key: Annotated[str, Header(alias="Idempotency-Key", min_length=1)],
    limiter: Annotated[SlidingWindowLimiter, Depends(get_rate_limiter)],
    workouts: Annotated[WorkoutService, Depends(get_workout_service)],
) -> dict[str, object]:
    if not (await limiter.allow(f"{current_user.firebase_uid}:POST", 10, 60)).allowed:
        raise HTTPException(
            status_code=429,
            detail={"code": "RATE_LIMIT_EXCEEDED", "message": "Rate limit exceeded. Please try again soon."},
        )
    return success((await workouts.log_workout(current_user, payload, idempotency_key)).model_dump(mode="json"))
