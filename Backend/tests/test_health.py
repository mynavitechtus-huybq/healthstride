from fastapi.testclient import TestClient
from app.main import app


def test_health_returns_the_standard_envelope() -> None:
    response = TestClient(app).get('/health')

    assert response.status_code == 200
    assert response.json() == {
        'data': {'status': 'ok'},
        'meta': {},
        'error': None,
    }
