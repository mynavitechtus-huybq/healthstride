import argparse
import asyncio
import random
import uuid
from datetime import UTC, datetime, timedelta

from sqlalchemy import select

from app.db.models import PointsTransaction, User, WorkoutCatalog, WorkoutLog
from app.db.session import get_session_factory
from app.features.workouts.domain import WorkoutType, calculate_workout_points

_SEED = 20260821
_SEED_NAMESPACE = uuid.UUID("1b0de458-c6e3-5a10-bfdc-6a52fb4921d5")
_CATALOG = (
    ("morning-cardio", "Morning Cardio", "A focused cardio session to start the day.", WorkoutType.cardio, 30, 220, True, 1),
    ("strength-foundations", "Strength Foundations", "A full-body weight lifting workout for building consistency.", WorkoutType.weight_lifting, 45, 280, True, 2),
    ("evening-yoga", "Evening Yoga", "A calm yoga flow for recovery and mobility.", WorkoutType.yoga, 25, 110, False, 3),
    ("interval-run", "Interval Run", "A short interval session for cardio fitness.", WorkoutType.cardio, 20, 190, False, 4),
)


async def seed(users_count: int) -> None:
    """Create deterministic catalog, users, workout logs, and point transactions."""
    rng = random.Random(_SEED)
    workout_types = tuple(WorkoutType)

    async with get_session_factory()() as session:
        existing_user_ids = set(
            (await session.scalars(select(User.firebase_uid).where(User.firebase_uid.like("seed-user-%")))).all()
        )
        existing_catalog_slugs = set((await session.scalars(select(WorkoutCatalog.slug))).all())

        catalog_rows = [
            WorkoutCatalog(
                id=uuid.uuid5(_SEED_NAMESPACE, f"catalog:{slug}"),
                slug=slug,
                name=name,
                description=description,
                workout_type=workout_type,
                duration_minutes=duration_minutes,
                estimated_calories=estimated_calories,
                is_featured=is_featured,
                sort_order=sort_order,
            )
            for slug, name, description, workout_type, duration_minutes, estimated_calories, is_featured, sort_order in _CATALOG
            if slug not in existing_catalog_slugs
        ]
        session.add_all(catalog_rows)

        seed_time = datetime(2026, 8, 21, 12, 0, tzinfo=UTC)
        for index in range(users_count):
            firebase_uid = f"seed-user-{index:04d}"
            if firebase_uid in existing_user_ids:
                continue

            workout_type = rng.choice(workout_types)
            duration_minutes = rng.choice((20, 30, 45, 60))
            award = calculate_workout_points(duration_minutes, workout_type, 0)
            user_id = uuid.uuid5(_SEED_NAMESPACE, f"user:{index}")
            workout_id = uuid.uuid5(_SEED_NAMESPACE, f"workout:{index}")
            logged_at = seed_time - timedelta(days=index % 28, minutes=index % 60)

            session.add(
                User(
                    id=user_id,
                    firebase_uid=firebase_uid,
                    display_name=f"Seed User {index:04d}",
                    email=f"seed.user.{index:04d}@example.test",
                    lifetime_points=award.awarded,
                    available_points=award.awarded,
                    current_streak=index % 8,
                )
            )
            session.add(
                WorkoutLog(
                    id=workout_id,
                    user_id=user_id,
                    workout_type=workout_type,
                    duration_minutes=duration_minutes,
                    distance_km=None,
                    logged_at=logged_at,
                    calories=duration_minutes * 7,
                    awarded_points=award.awarded,
                    capped=award.capped,
                    idempotency_key=f"seed-workout-{index:04d}",
                )
            )
            session.add(
                PointsTransaction(
                    id=uuid.uuid5(_SEED_NAMESPACE, f"points:{index}"),
                    user_id=user_id,
                    source_type="workout",
                    source_reference=str(workout_id),
                    lifetime_delta=award.awarded,
                    available_delta=award.awarded,
                )
            )

        await session.commit()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Seed deterministic HealthStride development data.")
    parser.add_argument("--users", type=int, default=1000, help="Number of deterministic users to create.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.users < 1:
        raise SystemExit("--users must be at least 1")
    asyncio.run(seed(args.users))


if __name__ == "__main__":
    main()
