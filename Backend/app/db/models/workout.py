import uuid
from datetime import datetime
from decimal import Decimal
from typing import TYPE_CHECKING

from sqlalchemy import (
    Boolean,
    CheckConstraint,
    DateTime,
    Enum,
    ForeignKey,
    Integer,
    Numeric,
    String,
    UniqueConstraint,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base
from app.features.workouts.domain import WorkoutType

if TYPE_CHECKING:
    from app.db.models.user import User


class WorkoutLog(Base):
    __tablename__ = "workout_logs"
    __table_args__ = (
        CheckConstraint("duration_minutes > 0", name="ck_workout_logs_duration_positive"),
        CheckConstraint("distance_km IS NULL OR distance_km >= 0", name="ck_workout_logs_distance_nonnegative"),
        CheckConstraint("calories >= 0", name="ck_workout_logs_calories_nonnegative"),
        CheckConstraint("awarded_points >= 0", name="ck_workout_logs_awarded_points_nonnegative"),
        CheckConstraint("awarded_points <= 300", name="ck_workout_logs_awarded_points_cap"),
        UniqueConstraint("user_id", "idempotency_key", name="uq_workout_logs_user_idempotency_key"),
    )

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    workout_type: Mapped[WorkoutType] = mapped_column(
        Enum(WorkoutType, name="workout_type", native_enum=False, create_constraint=True), nullable=False
    )
    duration_minutes: Mapped[int] = mapped_column(Integer, nullable=False)
    distance_km: Mapped[Decimal | None] = mapped_column(Numeric(8, 2), nullable=True)
    logged_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    calories: Mapped[int] = mapped_column(Integer, nullable=False)
    awarded_points: Mapped[int] = mapped_column(Integer, nullable=False, default=0, server_default="0")
    capped: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False, server_default="false")
    idempotency_key: Mapped[str] = mapped_column(String(255), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )

    user: Mapped["User"] = relationship(back_populates="workout_logs")
