import uuid
from datetime import datetime

from sqlalchemy import Boolean, CheckConstraint, DateTime, Enum, Integer, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.features.workouts.domain import WorkoutType


class WorkoutCatalog(Base):
    __tablename__ = "workout_catalog"
    __table_args__ = (
        CheckConstraint("duration_minutes > 0", name="ck_workout_catalog_duration_positive"),
        CheckConstraint("estimated_calories >= 0", name="ck_workout_catalog_calories_nonnegative"),
        CheckConstraint("sort_order >= 0", name="ck_workout_catalog_sort_order_nonnegative"),
    )

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    slug: Mapped[str] = mapped_column(String(120), unique=True, nullable=False)
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    workout_type: Mapped[WorkoutType] = mapped_column(
        Enum(WorkoutType, name="workout_type", native_enum=False, create_constraint=True), nullable=False
    )
    duration_minutes: Mapped[int] = mapped_column(Integer, nullable=False)
    estimated_calories: Mapped[int] = mapped_column(Integer, nullable=False)
    image_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    is_featured: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False, server_default="false")
    sort_order: Mapped[int] = mapped_column(Integer, nullable=False, default=0, server_default="0")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now()
    )
