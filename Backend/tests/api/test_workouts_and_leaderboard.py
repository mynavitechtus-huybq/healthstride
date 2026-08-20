import uuid
from collections.abc import Iterator
from datetime import UTC, datetime, timedelta

import pytest
from fastapi.testclient import TestClient

from app.core.rate_limit import SlidingWindowLimiter
from app.core.security import VerifiedIdentity
from app.db.models import User
from app.features.auth.dependencies import get_auth_service, get_firebase_verifier
from app.features.auth.service import AuthService
from app.features.leaderboard.router import get_leaderboard_service
from app.features.leaderboard.service import InMemoryLeaderboardRepository, LeaderboardService
from app.features.workouts.router import get_rate_limiter, get_workout_service
from app.features.workouts.service import InMemoryWorkoutRepository, WorkoutService
from app.main import app
from tests.fakes.firebase_verifier import FakeFirebaseVerifier


class InMemoryUserRepository:
    def __init__(self) -> None:
        self.user: User | None = None

    async def upsert(self, identity: VerifiedIdentity) -> User:
        if self.user is None:
            self.user = User(
                id=uuid.uuid4(),
                firebase_uid=identity.uid,
                email=identity.email,
                display_name=identity.display_name,
                lifetime_points=0,
                available_points=0,
                current_streak=0,
            )
        return self.user


class FakeRateRedis:
    def __init__(self) -> None:
        self.values: dict[str, dict[str, float]] = {}

    async def eval(self, _script: str, _numkeys: int, key: str, *args: object) -> int:
        now = float(args[0])
        window_seconds = int(args[1])
        limit = int(args[2])
        member = str(args[3])
        self.values[key] = {
            value: score for value, score in self.values.get(key, {}).items() if score > now - window_seconds
        }
        if len(self.values[key]) >= limit:
            return 0
        self.values[key][member] = now
        return 1


class FakeAsyncRedis:
    async def delete(self, _key: str) -> None:
        return None

    async def get(self, _key: str) -> None:
        return None

    async def set(self, _key: str, _value: str, **_kwargs: object) -> bool:
        return True

    async def eval(self, _script: str, _numkeys: int, *_keys_and_args: object) -> int:
        return 1


@pytest.fixture
def client() -> Iterator[TestClient]:
    verifier = FakeFirebaseVerifier()
    verifier.identity = VerifiedIdentity(uid="firebase-user-1", email="a@example.com", display_name="Ari")
    users = InMemoryUserRepository()
    redis = FakeAsyncRedis()
    app.dependency_overrides[get_firebase_verifier] = lambda: verifier
    app.dependency_overrides[get_auth_service] = lambda: AuthService(users)
    app.dependency_overrides[get_workout_service] = lambda: WorkoutService(InMemoryWorkoutRepository(), redis)
    app.dependency_overrides[get_leaderboard_service] = lambda: LeaderboardService(
        InMemoryLeaderboardRepository([]), redis
    )
    app.dependency_overrides[get_rate_limiter] = lambda: SlidingWindowLimiter(FakeRateRedis())
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


def test_workout_requires_an_idempotency_key(client: TestClient) -> None:
    logged_at = (datetime.now(UTC) - timedelta(minutes=1)).isoformat()
    response = client.post(
        "/v1/workouts",
        headers={"Authorization": "Bearer valid-token"},
        json={"workout_type": "cardio", "duration_minutes": 30, "logged_at": logged_at},
    )

    assert response.status_code == 422
    assert response.json()["error"]["code"] == "REQUEST_VALIDATION_FAILED"


@pytest.mark.parametrize(
    "payload",
    [
        {"workout_type": "cardio", "duration_minutes": 0},
        {"workout_type": "yoga", "duration_minutes": 30, "distance_km": "1.2"},
        {"workout_type": "cardio", "duration_minutes": 30, "logged_at": "2999-01-01T00:00:00Z"},
    ],
)
def test_workout_invalid_payload_uses_the_validation_envelope(
    client: TestClient, payload: dict[str, object]
) -> None:
    response = client.post(
        "/v1/workouts",
        headers={"Authorization": "Bearer valid-token", "Idempotency-Key": "request-invalid"},
        json=payload,
    )

    assert response.status_code == 422
    assert response.json()["data"] is None
    assert response.json()["error"]["code"] == "REQUEST_VALIDATION_FAILED"


def test_workout_openapi_documents_the_validation_error_envelope(client: TestClient) -> None:
    response = client.get("/openapi.json")

    schema = response.json()["paths"]["/v1/workouts"]["post"]["responses"]["422"]
    assert schema["content"]["application/json"]["schema"]["$ref"] == "#/components/schemas/ErrorEnvelope"


def test_workout_returns_a_standard_success_envelope(client: TestClient) -> None:
    logged_at = (datetime.now(UTC) - timedelta(minutes=1)).isoformat()
    response = client.post(
        "/v1/workouts",
        headers={"Authorization": "Bearer valid-token", "Idempotency-Key": "request-1"},
        json={"workout_type": "yoga", "duration_minutes": 30, "logged_at": logged_at},
    )

    assert response.status_code == 200
    assert response.json()["data"]["points_awarded"] == 90
    assert response.json()["error"] is None


def test_weekly_leaderboard_returns_the_authenticated_users_rank(client: TestClient) -> None:
    response = client.get("/v1/leaderboards/weekly", headers={"Authorization": "Bearer valid-token"})

    assert response.status_code == 200
    assert response.json()["data"]["current_user_rank"] is None
