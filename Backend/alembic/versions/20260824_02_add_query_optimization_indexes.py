"""Add covering index for the weekly leaderboard query.

Revision ID: 20260824_02
Revises: 20260821_01
Create Date: 2026-08-24
"""

from collections.abc import Sequence

from alembic import op

revision: str = "20260824_02"
down_revision: str | None = "20260821_01"
branch_labels: Sequence[str] | None = None
depends_on: Sequence[str] | None = None


def upgrade() -> None:
    # The date is the range filter, user_id is the join/group key, and
    # awarded_points is included so PostgreSQL can often avoid heap reads.
    op.create_index(
        "ix_workout_logs_leaderboard_logged_at_user_points",
        "workout_logs",
        ["logged_at", "user_id"],
        unique=False,
        postgresql_include=["awarded_points"],
    )


def downgrade() -> None:
    op.drop_index(
        "ix_workout_logs_leaderboard_logged_at_user_points",
        table_name="workout_logs",
    )
