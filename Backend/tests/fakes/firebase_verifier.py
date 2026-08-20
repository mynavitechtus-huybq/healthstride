from app.core.security import FirebaseVerificationError, VerifiedIdentity


class FakeFirebaseVerifier:
    """Test double for Firebase token verification at the external boundary."""

    def __init__(self) -> None:
        self.identity: VerifiedIdentity | None = None

    def verify(self, id_token: str) -> VerifiedIdentity:
        if id_token != "valid-token" or self.identity is None:
            raise FirebaseVerificationError("The Firebase ID token is invalid.")
        return self.identity
