import asyncio
import os
import subprocess
import sys
from pathlib import Path

import pytest
from sqlalchemy import func, inspect, select
from sqlalchemy.ext.asyncio import create_async_engine

from app.core.config import settings
from app.db.models import PointsTransaction, User, WorkoutLog
from app.db.seed import seed
from app.db.session import get_session_factory

_DATABASE_REQUIRED = pytest.mark.skipif(
    not settings.database_url,
    reason="DATABASE_URL is required for PostgreSQL migration verification",
)

_BACKEND_DIR = Path(__file__).resolve().parents[2]
_REQUIRED_TABLES = {"users", "workout_logs", "points_transactions", "workout_catalog"}


async def _table_names() -> set[str]:
    engine = create_async_engine(settings.database_url)
    try:
        async with engine.connect() as connection:
            return await connection.run_sync(
                lambda sync_connection: set(inspect(sync_connection).get_table_names())
            )
    finally:
        await engine.dispose()


async def _seeded_row_counts() -> tuple[int, int, int]:
    async with get_session_factory()() as session:
        return (
            (await session.scalar(select(func.count()).select_from(User))) or 0,
            (await session.scalar(select(func.count()).select_from(WorkoutLog))) or 0,
            (await session.scalar(select(func.count()).select_from(PointsTransaction))) or 0,
        )


def _run_alembic(*arguments: str) -> None:
    environment = {**os.environ, "DATABASE_URL": settings.database_url}
    subprocess.run(
        [
            sys.executable,
            "-m",
            "alembic",
            "-c",
            str(_BACKEND_DIR / "alembic.ini"),
            *arguments,
        ],
        check=True,
        cwd=_BACKEND_DIR,
        env=environment,
    )


@_DATABASE_REQUIRED
def test_vertical_slice_tables_exist_after_migration() -> None:
    assert _REQUIRED_TABLES <= asyncio.run(_table_names())


@_DATABASE_REQUIRED
def test_workout_log_constraint_and_migration_indexes_exist() -> None:
    async def schema_details() -> tuple[
        set[tuple[str, ...]],
        dict[str, set[tuple[str, tuple[str, ...]]]],
        dict[str, set[tuple[str | None, str, tuple[str, ...], tuple[str, ...]]]],
        dict[str, dict[str, str]],
    ]:
        engine = create_async_engine(settings.database_url)
        try:
            async with engine.connect() as connection:
                return await connection.run_sync(
                    lambda sync_connection: (
                        {
                            tuple(constraint["column_names"])
                            for constraint in inspect(sync_connection).get_unique_constraints("workout_logs")
                        },
                        {
                            table_name: {
                                (index["name"], tuple(index["column_names"]))
                                for index in inspect(sync_connection).get_indexes(table_name)
                            }
                            for table_name in _REQUIRED_TABLES
                        },
                        {
                            table_name: {
                                (
                                    foreign_key["name"],
                                    foreign_key["referred_table"],
                                    tuple(foreign_key["constrained_columns"]),
                                    tuple(foreign_key["referred_columns"]),
                                )
                                for foreign_key in inspect(sync_connection).get_foreign_keys(table_name)
                            }
                            for table_name in ("workout_logs", "points_transactions")
                        },
                        {
                            table_name: {
                                constraint["name"]: " ".join(constraint["sqltext"].lower().split())
                                for constraint in inspect(sync_connection).get_check_constraints(table_name)
                                if constraint["name"] is not None
                            }
                            for table_name in ("users", "workout_logs", "points_transactions")
                        },
                    )
                )
        finally:
            await engine.dispose()

    unique_constraints, indexes, foreign_keys, check_constraints = asyncio.run(schema_details())

    assert ("user_id", "idempotency_key") in unique_constraints
    assert {
        ("fk_workout_logs_user_id_users", "users", ("user_id",), ("id",)),
    } <= foreign_keys["workout_logs"]
    assert {
        ("fk_points_transactions_user_id_users", "users", ("user_id",), ("id",)),
    } <= foreign_keys["points_transactions"]
    assert {
        "ck_users_lifetime_gte_available": "lifetime_points >= available_points",
        "ck_users_available_points_nonnegative": "available_points >= 0",
    }.items() <= check_constraints["users"].items()
    assert {
        "ck_points_transactions_lifetime_nonnegative": "lifetime_delta >= 0",
    }.items() <= check_constraints["points_transactions"].items()
    assert {
        "ck_workout_logs_duration_positive": "duration_minutes > 0",
        "ck_workout_logs_awarded_points_nonnegative": "awarded_points >= 0",
    }.items() <= check_constraints["workout_logs"].items()
    assert {
        ("ix_users_email", ("email",)),
    } <= indexes["users"]
    assert {
        ("ix_workout_catalog_featured_sort", ("is_featured", "sort_order")),
        ("ix_workout_catalog_type", ("workout_type",)),
    } <= indexes["workout_catalog"]
    assert {
        ("ix_workout_logs_user_logged_at", ("user_id", "logged_at")),
        ("ix_workout_logs_logged_at", ("logged_at",)),
        (
            "ix_workout_logs_leaderboard_logged_at_user_points",
            ("logged_at", "user_id"),
        ),
    } <= indexes["workout_logs"]
    assert {
        ("ix_points_transactions_user_created_at", ("user_id", "created_at")),
        ("ix_points_transactions_source", ("source_type", "source_reference")),
    } <= indexes["points_transactions"]


@_DATABASE_REQUIRED
def test_seed_creates_and_reuses_deterministic_rows() -> None:
    async def seed_twice() -> tuple[tuple[int, int, int], tuple[int, int, int]]:
        await seed(1000)
        initial_counts = await _seeded_row_counts()
        await seed(1000)
        return initial_counts, await _seeded_row_counts()

    initial_counts, repeated_counts = asyncio.run(seed_twice())

    assert all(count >= 1000 for count in initial_counts)
    assert repeated_counts == initial_counts


@_DATABASE_REQUIRED
def test_alembic_downgrade_and_reupgrade_recreates_vertical_slice_tables() -> None:
    _run_alembic("downgrade", "base")
    _run_alembic("upgrade", "head")

    assert _REQUIRED_TABLES <= asyncio.run(_table_names())
