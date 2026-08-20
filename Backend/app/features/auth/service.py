from typing import Protocol

from sqlalchemy import func
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import VerifiedIdentity
from app.db.models import User


class UserRepository(Protocol):
    async def upsert(self, identity: VerifiedIdentity) -> User: ...


class SqlAlchemyUserRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def upsert(self, identity: VerifiedIdentity) -> User:
        statement = (
            insert(User)
            .values(
                firebase_uid=identity.uid,
                email=identity.email,
                display_name=identity.display_name,
            )
            .on_conflict_do_update(
                index_elements=[User.firebase_uid],
                set_={
                    "email": identity.email,
                    "display_name": identity.display_name,
                    "updated_at": func.now(),
                },
            )
            .returning(User)
        )
        user = (await self._session.execute(statement)).scalar_one()

        await self._session.commit()
        await self._session.refresh(user)
        return user


class AuthService:
    def __init__(self, users: UserRepository) -> None:
        self._users = users

    async def upsert_verified_identity(self, identity: VerifiedIdentity) -> User:
        return await self._users.upsert(identity)
