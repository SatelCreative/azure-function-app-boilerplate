import pytest
from starlette.testclient import TestClient

from webapp.main import app


@pytest.fixture()
def client():
    return TestClient(app)
