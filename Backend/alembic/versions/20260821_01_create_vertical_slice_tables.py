"""Create HealthStride August vertical-slice tables.

Revision ID: 20260821_01
Revises:
Create Date: 2026-08-21
"""

from collections.abc import Sequence

import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

from alembic import op

revision: str = "20260821_01"
down_revision: str | None = None
branch_labels: Sequence[str] | None = None
depends_on: Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("firebase_uid", sa.String(length=128), nullable=False),
        sa.Column("display_name", sa.String(length=120), nullable=False),
        sa.Column("email", sa.String(length=320), nullable=False),
        sa.Column("lifetime_points", sa.Integer(), server_default="0", nullable=False),
        sa.Column("available_points", sa.Integer(), server_default="0", nullable=False),
        sa.Column("current_streak", sa.Integer(), server_default="0", nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.CheckConstraint("lifetime_points >= available_points", name="ck_users_lifetime_gte_available"),
        sa.CheckConstraint("available_points >= 0", name="ck_users_available_points_nonnegative"),
        sa.CheckConstraint("current_streak >= 0", name="ck_users_current_streak_nonnegative"),
        sa.PrimaryKeyConstraint("id", name="pk_users"),
        sa.UniqueConstraint("firebase_uid", name="uq_users_firebase_uid"),
    )
    op.create_index("ix_users_email", "users", ["email"], unique=False)

    op.create_table(
        "workout_catalog",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("slug", sa.String(length=120), nullable=False),
        sa.Column("name", sa.String(length=120), nullable=False),
        sa.Column("description", sa.Text(), nullable=False),
        sa.Column("workout_type", sa.String(length=32), nullable=False),
        sa.Column("duration_minutes", sa.Integer(), nullable=False),
        sa.Column("estimated_calories", sa.Integer(), nullable=False),
        sa.Column("image_url", sa.String(length=500), nullable=True),
        sa.Column("is_featured", sa.Boolean(), server_default=sa.text("false"), nullable=False),
        sa.Column("sort_order", sa.Integer(), server_default="0", nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.CheckConstraint("workout_type IN ('cardio', 'weight_lifting', 'yoga')", name="ck_workout_catalog_type"),
        sa.CheckConstraint("duration_minutes > 0", name="ck_workout_catalog_duration_positive"),
        sa.CheckConstraint("estimated_calories >= 0", name="ck_workout_catalog_calories_nonnegative"),
        sa.CheckConstraint("sort_order >= 0", name="ck_workout_catalog_sort_order_nonnegative"),
        sa.PrimaryKeyConstraint("id", name="pk_workout_catalog"),
        sa.UniqueConstraint("slug", name="uq_workout_catalog_slug"),
    )
    op.create_index("ix_workout_catalog_featured_sort", "workout_catalog", ["is_featured", "sort_order"], unique=False)
    op.create_index("ix_workout_catalog_type", "workout_catalog", ["workout_type"], unique=False)

    op.create_table(
        "workout_logs",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("workout_type", sa.String(length=32), nullable=False),
        sa.Column("duration_minutes", sa.Integer(), nullable=False),
        sa.Column("distance_km", sa.Numeric(precision=8, scale=2), nullable=True),
        sa.Column("logged_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("calories", sa.Integer(), nullable=False),
        sa.Column("awarded_points", sa.Integer(), server_default="0", nullable=False),
        sa.Column("capped", sa.Boolean(), server_default=sa.text("false"), nullable=False),
        sa.Column("idempotency_key", sa.String(length=255), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.CheckConstraint("workout_type IN ('cardio', 'weight_lifting', 'yoga')", name="ck_workout_logs_type"),
        sa.CheckConstraint("duration_minutes > 0", name="ck_workout_logs_duration_positive"),
        sa.CheckConstraint("distance_km IS NULL OR distance_km >= 0", name="ck_workout_logs_distance_nonnegative"),
        sa.CheckConstraint("calories >= 0", name="ck_workout_logs_calories_nonnegative"),
        sa.CheckConstraint("awarded_points >= 0", name="ck_workout_logs_awarded_points_nonnegative"),
        sa.CheckConstraint("awarded_points <= 300", name="ck_workout_logs_awarded_points_cap"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], name="fk_workout_logs_user_id_users", ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id", name="pk_workout_logs"),
        sa.UniqueConstraint("user_id", "idempotency_key", name="uq_workout_logs_user_idempotency_key"),
    )
    op.create_index("ix_workout_logs_user_logged_at", "workout_logs", ["user_id", "logged_at"], unique=False)
    op.create_index("ix_workout_logs_logged_at", "workout_logs", ["logged_at"], unique=False)

    op.create_table(
        "points_transactions",
        sa.Column("id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("source_type", sa.String(length=64), nullable=False),
        sa.Column("source_reference", sa.String(length=255), nullable=False),
        sa.Column("lifetime_delta", sa.Integer(), nullable=False),
        sa.Column("available_delta", sa.Integer(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.CheckConstraint("lifetime_delta >= 0", name="ck_points_transactions_lifetime_nonnegative"),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"], name="fk_points_transactions_user_id_users", ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id", name="pk_points_transactions"),
    )
    op.create_index("ix_points_transactions_user_created_at", "points_transactions", ["user_id", "created_at"], unique=False)
    op.create_index("ix_points_transactions_source", "points_transactions", ["source_type", "source_reference"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_points_transactions_source", table_name="points_transactions")
    op.drop_index("ix_points_transactions_user_created_at", table_name="points_transactions")
    op.drop_table("points_transactions")
    op.drop_index("ix_workout_logs_logged_at", table_name="workout_logs")
    op.drop_index("ix_workout_logs_user_logged_at", table_name="workout_logs")
    op.drop_table("workout_logs")
    op.drop_index("ix_workout_catalog_type", table_name="workout_catalog")
    op.drop_index("ix_workout_catalog_featured_sort", table_name="workout_catalog")
    op.drop_table("workout_catalog")
    op.drop_index("ix_users_email", table_name="users")
    op.drop_table("users")
