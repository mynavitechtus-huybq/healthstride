from pydantic import BaseModel, ConfigDict

from app.db.models import User, WorkoutCatalog
from app.features.workouts.domain import WorkoutType


class ProfileSchema(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    display_name: str
    email: str
    lifetime_points: int
    available_points: int
    current_streak: int

    @classmethod
    def from_user(cls, user: User) -> "ProfileSchema":
        return cls.model_validate(user)


class MeSchema(BaseModel):
    profile: ProfileSchema


class WorkoutSummarySchema(BaseModel):
    slug: str
    name: str
    description: str
    workout_type: WorkoutType
    duration_minutes: int
    estimated_calories: int
    image_url: str | None

    @classmethod
    def from_catalog(cls, workout: WorkoutCatalog) -> "WorkoutSummarySchema":
        return cls(
            slug=workout.slug,
            name=workout.name,
            description=workout.description,
            workout_type=workout.workout_type,
            duration_minutes=workout.duration_minutes,
            estimated_calories=workout.estimated_calories,
            image_url=workout.image_url,
        )


class HomeSchema(BaseModel):
    profile: ProfileSchema
    popular_workouts: list[WorkoutSummarySchema]
    today_plan: WorkoutSummarySchema | None
