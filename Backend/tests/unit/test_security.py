import os
from types import SimpleNamespace

import pytest

from app.core import security


def test_verifier_initializes_admin_once_with_configured_project_and_adc_path(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    initialized: list[dict[str, object] | None] = []
    app_initialized = False
    configured = SimpleNamespace(
        firebase_project_id="healthstride-test",
        google_application_credentials="/tmp/firebase-adc.json",
    )

    def no_default_app() -> object:
        if app_initialized:
            return object()
        raise ValueError("No Firebase app")

    def initialize_app(*, options: dict[str, object] | None = None) -> object:
        nonlocal app_initialized
        app_initialized = True
        initialized.append(options)
        return object()

    monkeypatch.delenv("GOOGLE_APPLICATION_CREDENTIALS", raising=False)
    monkeypatch.setattr(security, "settings", configured)
    monkeypatch.setattr(security.firebase_admin, "get_app", no_default_app)
    monkeypatch.setattr(security.firebase_admin, "initialize_app", initialize_app)
    monkeypatch.setattr(
        security.firebase_auth,
        "verify_id_token",
        lambda _token, check_revoked: {"uid": "firebase-user", "email": "user@example.com"},
    )

    verifier = security.FirebaseAdminVerifier()
    assert verifier.verify("valid-token").uid == "firebase-user"
    assert verifier.verify("valid-token").uid == "firebase-user"

    assert initialized == [{"projectId": "healthstride-test"}]
    assert os.environ["GOOGLE_APPLICATION_CREDENTIALS"] == "/tmp/firebase-adc.json"
