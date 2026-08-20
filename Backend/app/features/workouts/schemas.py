from datetime import UTC, datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, Field, field_validator, model_validator

from app.features.workouts.domain import WorkoutType


class WorkoutCreate(BaseModel):
    workout_type: WorkoutType
    duration_minutes: int = Field(gt=0)
    distance_km: Decimal | None = Field(default=None, ge=0)
    logged_at: datetime

    @field_validator("logged_at")
    @classmethod
    def logged_at_must_not_be_in_the_future(cls, value: datetime) -> datetime:
        value_utc = value.astimezone(UTC) if value.tzinfo is not None else value.replace(tzinfo=UTC)
        if value_utc > datetime.now(UTC):
            raise ValueError("logged_at must not be in the future")
        return value_utc

    @model_validator(mode="after")
    def distance_is_only_valid_for_cardio(self) -> "WorkoutCreate":
        if self.distance_km is not None and self.workout_type is not WorkoutType.cardio:
            raise ValueError("distance_km is only valid for cardio workouts")
        return self


class LoggedWorkoutSchema(BaseModel):
    id: UUID
    workout_type: WorkoutType
    duration_minutes: int
    distance_km: Decimal | None
    logged_at: datetime
    calories: int
    points_awarded: int
    capped: bool


class LeaderboardRowSchema(BaseModel):
    rank: int
    user_id: UUID
    display_name: str
    points: int


class WeeklyLeaderboardSchema(BaseModel):
    week_start: str
    rows: list[LeaderboardRowSchema]
    current_user_rank: int | None
