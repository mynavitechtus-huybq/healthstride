from typing import Protocol

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import User, WorkoutCatalog
from app.features.home.schemas import HomeSchema, ProfileSchema, WorkoutSummarySchema


class HomeRepository(Protocol):
    async def list_popular_workouts(self) -> list[WorkoutCatalog]: ...


class SqlAlchemyHomeRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def list_popular_workouts(self) -> list[WorkoutCatalog]:
        statement = (
            select(WorkoutCatalog)
            .where(WorkoutCatalog.is_featured.is_(True))
            .order_by(WorkoutCatalog.sort_order)
            .limit(3)
        )
        return list((await self._session.scalars(statement)).all())


class HomeService:
    def __init__(self, workouts: HomeRepository) -> None:
        self._workouts = workouts

    async def get_home(self, user: User) -> HomeSchema:
        popular_workouts = [
            WorkoutSummarySchema.from_catalog(workout)
            for workout in await self._workouts.list_popular_workouts()
        ]
        return HomeSchema(
            profile=ProfileSchema.from_user(user),
            popular_workouts=popular_workouts,
            today_plan=popular_workouts[0] if popular_workouts else None,
        )
