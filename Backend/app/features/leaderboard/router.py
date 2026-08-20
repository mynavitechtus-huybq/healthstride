from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.api_envelope import ErrorEnvelope, SuccessEnvelope, success
from app.core.rate_limit import SlidingWindowLimiter
from app.core.redis import get_redis_client
from app.db.models import User
from app.db.session import get_session
from app.features.auth.dependencies import get_current_user
from app.features.leaderboard.service import (
    LeaderboardCache,
    LeaderboardService,
    SqlAlchemyLeaderboardRepository,
)
from app.features.workouts.router import get_rate_limiter
from app.features.workouts.schemas import WeeklyLeaderboardSchema

router = APIRouter(tags=["leaderboard"])


def get_leaderboard_service(
    session: Annotated[AsyncSession, Depends(get_session)],
    cache: Annotated[LeaderboardCache, Depends(get_redis_client)],
) -> LeaderboardService:
    return LeaderboardService(SqlAlchemyLeaderboardRepository(session), cache)


@router.get(
    "/leaderboards/weekly",
    response_model=SuccessEnvelope[WeeklyLeaderboardSchema],
    responses={401: {"model": ErrorEnvelope}, 429: {"model": ErrorEnvelope}},
)
async def get_weekly_leaderboard(
    current_user: Annotated[User, Depends(get_current_user)],
    limiter: Annotated[SlidingWindowLimiter, Depends(get_rate_limiter)],
    leaderboards: Annotated[LeaderboardService, Depends(get_leaderboard_service)],
) -> dict[str, object]:
    if not (await limiter.allow(f"{current_user.firebase_uid}:GET", 100, 60)).allowed:
        raise HTTPException(
            status_code=429,
            detail={"code": "RATE_LIMIT_EXCEEDED", "message": "Rate limit exceeded. Please try again soon."},
        )
    return success((await leaderboards.get_weekly(current_user)).model_dump(mode="json"))
