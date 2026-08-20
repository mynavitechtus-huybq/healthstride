import uuid
from datetime import datetime
from typing import TYPE_CHECKING

from sqlalchemy import CheckConstraint, DateTime, Integer, String, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base

if TYPE_CHECKING:
    from app.db.models.points_transaction import PointsTransaction
    from app.db.models.workout import WorkoutLog


class User(Base):
    __tablename__ = "users"
    __table_args__ = (
        CheckConstraint("lifetime_points >= available_points", name="ck_users_lifetime_gte_available"),
        CheckConstraint("available_points >= 0", name="ck_users_available_points_nonnegative"),
        CheckConstraint("current_streak >= 0", name="ck_users_current_streak_nonnegative"),
    )

    id: Mapped[uuid.UUID] = mapped_column(primary_key=True, default=uuid.uuid4)
    firebase_uid: Mapped[str] = mapped_column(String(128), unique=True, nullable=False)
    display_name: Mapped[str] = mapped_column(String(120), nullable=False)
    email: Mapped[str] = mapped_column(String(320), nullable=False)
    lifetime_points: Mapped[int] = mapped_column(Integer, nullable=False, default=0, server_default="0")
    available_points: Mapped[int] = mapped_column(Integer, nullable=False, default=0, server_default="0")
    current_streak: Mapped[int] = mapped_column(Integer, nullable=False, default=0, server_default="0")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now()
    )

    workout_logs: Mapped[list["WorkoutLog"]] = relationship(back_populates="user")
    points_transactions: Mapped[list["PointsTransaction"]] = relationship(back_populates="user")
