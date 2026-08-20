import asyncio
from types import SimpleNamespace

from sqlalchemy.dialects import postgresql

from app.core.security import VerifiedIdentity
from app.features.auth.service import SqlAlchemyUserRepository


class RecordingSession:
    def __init__(self) -> None:
        self.statement: object | None = None

    async def execute(self, statement: object) -> SimpleNamespace:
        self.statement = statement
        return SimpleNamespace(scalar_one=lambda: SimpleNamespace())

    async def commit(self) -> None:
        pass

    async def refresh(self, _user: object) -> None:
        pass


def test_user_upsert_is_a_postgresql_atomic_conflict_update() -> None:
    session = RecordingSession()
    repository = SqlAlchemyUserRepository(session)  # type: ignore[arg-type]

    asyncio.run(
        repository.upsert(
            VerifiedIdentity(uid="firebase-user", email="new@example.com", display_name="New Name")
        )
    )

    assert session.statement is not None
    sql = str(
        session.statement.compile(  # type: ignore[union-attr]
            dialect=postgresql.dialect(), compile_kwargs={"literal_binds": True}
        )
    )
    assert "ON CONFLICT (firebase_uid) DO UPDATE" in sql
    assert "email = 'new@example.com'" in sql
    assert "display_name = 'New Name'" in sql
    update_clause = sql.partition("DO UPDATE SET")[2].partition("RETURNING")[0]
    assert "lifetime_points" not in update_clause
    assert "available_points" not in update_clause
    assert "current_streak" not in update_clause
