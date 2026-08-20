import uuid
from collections.abc import Iterator

import pytest
from fastapi.testclient import TestClient
from pydantic import BaseModel

from app.core.security import VerifiedIdentity
from app.db.models import User, WorkoutCatalog
from app.features.auth.dependencies import get_auth_service, get_firebase_verifier
from app.features.auth.service import AuthService
from app.features.home.router import get_home_service
from app.features.home.service import HomeService
from app.features.workouts.domain import WorkoutType
from app.main import app
from tests.fakes.firebase_verifier import FakeFirebaseVerifier


class ValidationProbe(BaseModel):
    duration_minutes: int


class InMemoryUserRepository:
    def __init__(self) -> None:
        self.users: dict[str, User] = {}

    async def upsert(self, identity: VerifiedIdentity) -> User:
        user = self.users.get(identity.uid)
        if user is None:
            user = User(
                id=uuid.uuid4(),
                firebase_uid=identity.uid,
                email=identity.email,
                display_name=identity.display_name,
                lifetime_points=0,
                available_points=0,
                current_streak=0,
            )
            self.users[identity.uid] = user
        else:
            user.email = identity.email
            user.display_name = identity.display_name
        return user


class InMemoryHomeRepository:
    async def list_popular_workouts(self) -> list[WorkoutCatalog]:
        return [
            WorkoutCatalog(
                id=uuid.uuid4(),
                slug="morning-cardio",
                name="Morning Cardio",
                description="A focused cardio session to start the day.",
                workout_type=WorkoutType.cardio,
                duration_minutes=30,
                estimated_calories=220,
                image_url=None,
                is_featured=True,
                sort_order=1,
            )
        ]


@pytest.fixture
def fake_verifier() -> FakeFirebaseVerifier:
    return FakeFirebaseVerifier()


@pytest.fixture
def client(fake_verifier: FakeFirebaseVerifier) -> Iterator[TestClient]:
    app.dependency_overrides[get_firebase_verifier] = lambda: fake_verifier
    app.dependency_overrides[get_auth_service] = lambda: AuthService(InMemoryUserRepository())
    app.dependency_overrides[get_home_service] = lambda: HomeService(InMemoryHomeRepository())
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()


def test_home_upserts_the_verified_identity_and_returns_data(
    client: TestClient, fake_verifier: FakeFirebaseVerifier
) -> None:
    fake_verifier.identity = VerifiedIdentity(
        uid="firebase-user-1", email="user@example.com", display_name="Ari"
    )

    response = client.get("/v1/home", headers={"Authorization": "Bearer valid-token"})
    body = response.json()

    assert response.status_code == 200
    assert body["error"] is None
    assert body["data"]["profile"] == {
        "display_name": "Ari",
        "email": "user@example.com",
        "lifetime_points": 0,
        "available_points": 0,
        "current_streak": 0,
    }
    assert body["data"]["popular_workouts"] == [
        {
            "slug": "morning-cardio",
            "name": "Morning Cardio",
            "description": "A focused cardio session to start the day.",
            "workout_type": "cardio",
            "duration_minutes": 30,
            "estimated_calories": 220,
            "image_url": None,
        }
    ]
    assert body["data"]["today_plan"] == body["data"]["popular_workouts"][0]


def test_home_rejects_missing_bearer_token(client: TestClient) -> None:
    response = client.get("/v1/home")

    assert response.status_code == 401
    assert response.json()["error"]["code"] == "AUTHENTICATION_REQUIRED"


def test_home_rejects_a_malformed_bearer_token(client: TestClient) -> None:
    response = client.get("/v1/home", headers={"Authorization": "Token valid-token"})

    assert response.status_code == 401
    assert response.json()["error"]["code"] == "AUTHENTICATION_REQUIRED"


def test_home_rejects_an_invalid_verified_token(
    client: TestClient, fake_verifier: FakeFirebaseVerifier
) -> None:
    fake_verifier.identity = VerifiedIdentity(
        uid="firebase-user-1", email="user@example.com", display_name="Ari"
    )

    response = client.get("/v1/home", headers={"Authorization": "Bearer invalid-token"})

    assert response.status_code == 401
    assert response.json()["error"]["code"] == "AUTHENTICATION_REQUIRED"


def test_me_returns_the_server_verified_profile(
    client: TestClient, fake_verifier: FakeFirebaseVerifier
) -> None:
    fake_verifier.identity = VerifiedIdentity(
        uid="firebase-user-2", email="kai@example.com", display_name="Kai"
    )

    response = client.get("/v1/me", headers={"Authorization": "Bearer valid-token"})

    assert response.status_code == 200
    assert response.json() == {
        "data": {
            "profile": {
                "display_name": "Kai",
                "email": "kai@example.com",
                "lifetime_points": 0,
                "available_points": 0,
                "current_streak": 0,
            }
        },
        "meta": {},
        "error": None,
    }


def test_missing_route_uses_the_standard_error_envelope(client: TestClient) -> None:
    response = client.get("/missing")

    assert response.status_code == 404
    assert response.json() == {
        "data": None,
        "meta": {},
        "error": {
            "code": "REQUEST_FAILED",
            "message": "The request could not be completed.",
        },
    }


def test_request_validation_uses_the_standard_error_envelope(client: TestClient) -> None:
    async def validation_probe(payload: ValidationProbe) -> dict[str, object]:
        return {"duration_minutes": payload.duration_minutes}

    app.add_api_route("/_validation-probe", validation_probe, methods=["POST"])
    try:
        response = client.post("/_validation-probe", json={"duration_minutes": "thirty"})
    finally:
        app.router.routes.pop()

    assert response.status_code == 422
    body = response.json()
    assert body["data"] is None
    assert body["meta"] == {}
    assert body["error"]["code"] == "REQUEST_VALIDATION_FAILED"
    assert body["error"]["message"] == "Request validation failed."
    assert body["error"]["details"] == [
        {
            "loc": ["body", "duration_minutes"],
            "msg": "Input should be a valid integer, unable to parse string as an integer",
            "type": "int_parsing",
        }
    ]


def test_openapi_documents_envelopes_for_protected_routes(client: TestClient) -> None:
    document = client.get("/openapi.json").json()

    for path in ("/v1/me", "/v1/home"):
        responses = document["paths"][path]["get"]["responses"]
        success_schema = responses["200"]["content"]["application/json"]["schema"]
        unauthorized_schema = responses["401"]["content"]["application/json"]["schema"]

        assert "$ref" in success_schema
        assert unauthorized_schema == {"$ref": "#/components/schemas/ErrorEnvelope"}

        success_name = success_schema["$ref"].rpartition("/")[2]
        assert set(document["components"]["schemas"][success_name]["properties"]) == {
            "data",
            "meta",
            "error",
        }
