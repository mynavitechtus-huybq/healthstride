import os
from dataclasses import dataclass
from threading import Lock
from typing import Any, Protocol

import firebase_admin  # type: ignore[import-untyped]
from firebase_admin import auth as firebase_auth

from app.core.config import settings

_firebase_app_lock = Lock()


@dataclass(frozen=True)
class VerifiedIdentity:
    uid: str
    email: str
    display_name: str


class FirebaseVerifier(Protocol):
    def verify(self, id_token: str) -> VerifiedIdentity: ...


class FirebaseVerificationError(Exception):
    """Raised when Firebase cannot establish the caller's identity."""


def initialize_firebase_admin() -> None:
    """Initialize the default Admin SDK app once, using configured ADC inputs."""
    try:
        firebase_admin.get_app()
        return
    except ValueError:
        pass

    with _firebase_app_lock:
        try:
            firebase_admin.get_app()
            return
        except ValueError:
            if settings.google_application_credentials:
                os.environ.setdefault(
                    "GOOGLE_APPLICATION_CREDENTIALS", settings.google_application_credentials
                )

            options = (
                {"projectId": settings.firebase_project_id} if settings.firebase_project_id else None
            )
            firebase_admin.initialize_app(options=options)


class FirebaseAdminVerifier:
    """Production verifier backed by the Firebase Admin SDK."""

    def verify(self, id_token: str) -> VerifiedIdentity:
        try:
            initialize_firebase_admin()
            claims: dict[str, Any] = firebase_auth.verify_id_token(id_token, check_revoked=True)
        except Exception as exc:
            raise FirebaseVerificationError("The Firebase ID token is invalid.") from exc

        uid = claims.get("uid") or claims.get("sub")
        email = claims.get("email")
        if not isinstance(uid, str) or not uid or not isinstance(email, str) or not email:
            raise FirebaseVerificationError("The Firebase ID token has incomplete identity claims.")

        display_name = claims.get("name")
        if not isinstance(display_name, str) or not display_name:
            display_name = email.partition("@")[0]

        return VerifiedIdentity(uid=uid, email=email, display_name=display_name)
