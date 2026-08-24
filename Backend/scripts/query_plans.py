"""Run the three representative HealthStride queries with PostgreSQL plans.

Usage:
    uv run python -m scripts.query_plans --output-dir ../Document/HealthStride/evidence/performance
"""

import argparse
import asyncio
from pathlib import Path

from sqlalchemy import text
from sqlalchemy.ext.asyncio import create_async_engine

from app.core.config import settings

QUERIES: dict[str, str] = {
    "home": """
        SELECT slug, name, workout_type, duration_minutes, estimated_calories
        FROM workout_catalog
        WHERE is_featured = TRUE
        ORDER BY sort_order ASC, name ASC
        LIMIT 6
    """,
    "history": """
        SELECT id, workout_type, duration_minutes, awarded_points, logged_at
        FROM workout_logs
        WHERE user_id = (
            SELECT id FROM users WHERE firebase_uid = 'seed-user-0000'
        )
          AND logged_at >= TIMESTAMPTZ '2026-08-17 00:00:00+00'
          AND logged_at < TIMESTAMPTZ '2026-08-24 00:00:00+00'
        ORDER BY logged_at DESC
        LIMIT 20
    """,
    "leaderboard": """
        SELECT u.id, u.display_name, COALESCE(SUM(w.awarded_points), 0) AS points
        FROM users AS u
        JOIN workout_logs AS w ON w.user_id = u.id
        WHERE w.logged_at >= TIMESTAMPTZ '2026-08-17 00:00:00+00'
          AND w.logged_at < TIMESTAMPTZ '2026-08-24 00:00:00+00'
        GROUP BY u.id, u.display_name
        ORDER BY points DESC, u.id
        LIMIT 50
    """,
}


async def collect_plans() -> str:
    if not settings.database_url:
        raise RuntimeError("DATABASE_URL chưa được cấu hình trong Backend/.env")

    engine = create_async_engine(settings.database_url)
    try:
        sections: list[str] = []
        async with engine.connect() as connection:
            for name, query in QUERIES.items():
                result = await connection.execute(
                    text(f"EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) {query}")
                )
                plan = "\n".join(str(row[0]) for row in result)
                sections.append(f"## {name}\n\n```text\n{plan}\n```")
        return "# Kết quả EXPLAIN ANALYZE\n\n" + "\n\n".join(sections) + "\n"
    finally:
        await engine.dispose()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-dir", type=Path, help="Thư mục ghi file kết quả")
    return parser.parse_args()


async def main() -> None:
    args = parse_args()
    report = await collect_plans()
    if args.output_dir:
        args.output_dir.mkdir(parents=True, exist_ok=True)
        output = args.output_dir / "2026-08-24-after.md"
        output.write_text(report, encoding="utf-8")
        print(f"Đã ghi {output}")
    else:
        print(report)


if __name__ == "__main__":
    asyncio.run(main())
