from typing import Annotated

from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import (
    FirebaseAdminVerifier,
    FirebaseVerificationError,
    FirebaseVerifier,
)
from app.db.models import User
from app.db.session import get_session
from app.features.auth.service import AuthService, SqlAlchemyUserRepository

_bearer_scheme = HTTPBearer(auto_error=False)


def get_firebase_verifier() -> FirebaseVerifier:
    return FirebaseAdminVerifier()


def get_auth_service(session: Annotated[AsyncSession, Depends(get_session)]) -> AuthService:
    return AuthService(SqlAlchemyUserRepository(session))


async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(_bearer_scheme)],
    verifier: Annotated[FirebaseVerifier, Depends(get_firebase_verifier)],
    auth_service: Annotated[AuthService, Depends(get_auth_service)],
) -> User:
    if credentials is None or credentials.scheme.lower() != "bearer" or not credentials.credentials:
        raise _authentication_required()

    try:
        identity = verifier.verify(credentials.credentials)
    except FirebaseVerificationError:
        raise _authentication_required() from None

    return await auth_service.upsert_verified_identity(identity)


def _authentication_required() -> HTTPException:
    return HTTPException(
        status_code=401,
        detail={
            "code": "AUTHENTICATION_REQUIRED",
            "message": "A valid Bearer token is required.",
        },
    )
