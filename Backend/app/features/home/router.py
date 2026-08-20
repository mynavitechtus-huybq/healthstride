from typing import Annotated

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.api_envelope import ErrorEnvelope, SuccessEnvelope, success
from app.db.models import User
from app.db.session import get_session
from app.features.auth.dependencies import get_current_user
from app.features.home.schemas import HomeSchema, MeSchema, ProfileSchema
from app.features.home.service import HomeService, SqlAlchemyHomeRepository

router = APIRouter(tags=["home"])


def get_home_service(session: Annotated[AsyncSession, Depends(get_session)]) -> HomeService:
    return HomeService(SqlAlchemyHomeRepository(session))


@router.get(
    "/me",
    response_model=SuccessEnvelope[MeSchema],
    responses={401: {"model": ErrorEnvelope}},
)
async def get_me(current_user: Annotated[User, Depends(get_current_user)]) -> dict[str, object]:
    return success({"profile": ProfileSchema.from_user(current_user).model_dump(mode="json")})


@router.get(
    "/home",
    response_model=SuccessEnvelope[HomeSchema],
    responses={401: {"model": ErrorEnvelope}},
)
async def get_home(
    current_user: Annotated[User, Depends(get_current_user)],
    home_service: Annotated[HomeService, Depends(get_home_service)],
) -> dict[str, object]:
    return success((await home_service.get_home(current_user)).model_dump(mode="json"))
