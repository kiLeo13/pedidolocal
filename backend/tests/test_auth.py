from fastapi.testclient import TestClient

from app.core.config import get_settings
from tests.conftest import login_headers, register_customer


def test_customer_registration_login_me_and_duplicate(client: TestClient) -> None:
    user = register_customer(client)

    assert user["email"] == "customer@example.com"
    assert user["role"] == "customer"
    assert "hashed_password" not in user
    assert user["profile"]["city"] == "Pedido Local"

    duplicate = client.post(
        "/auth/register",
        json={
            "email": "customer@example.com",
            "password": "Customer12345",
            "full_name": "Duplicate User",
            "phone": "11988888888",
            "address_line": "Second Street, 200",
            "city": "Pedido Local",
            "birth_date": "1991-01-01",
        },
    )
    assert duplicate.status_code == 409

    headers = login_headers(client, "customer@example.com", "Customer12345")
    me = client.get("/auth/me", headers=headers)

    assert me.status_code == 200
    assert me.json()["email"] == "customer@example.com"
    assert "hashed_password" not in me.json()

    invalid_login = client.post(
        "/auth/token",
        data={"username": "customer@example.com", "password": "wrong-password"},
    )
    assert invalid_login.status_code == 401


def test_protected_endpoint_rejects_missing_token(client: TestClient) -> None:
    response = client.get("/auth/me")

    assert response.status_code == 401
    assert response.json()["detail"] == "not authenticated"


def test_customer_registration_requires_profile_fields(client: TestClient) -> None:
    response = client.post(
        "/auth/register",
        json={
            "email": "customer@example.com",
            "password": "Customer12345",
            "full_name": "Customer User",
            "role": "customer",
        },
    )

    assert response.status_code == 422
    assert "customer accounts require phone, address_line, and city" in response.text


def test_development_admin_registration_login_and_me(client: TestClient) -> None:
    response = client.post(
        "/auth/register",
        json={
            "email": "admin@example.com",
            "password": "Admin12345",
            "full_name": "Admin User",
            "role": "admin",
        },
    )

    assert response.status_code == 201, response.text
    user = response.json()
    assert user["email"] == "admin@example.com"
    assert user["role"] == "admin"
    assert user["profile"] is None

    headers = login_headers(client, "admin@example.com", "Admin12345")
    me = client.get("/auth/me", headers=headers)

    assert me.status_code == 200
    assert me.json()["role"] == "admin"


def test_admin_self_registration_rejected_outside_development(
    client: TestClient,
    monkeypatch,
) -> None:
    monkeypatch.setenv("ENVIRONMENT", "production")
    get_settings.cache_clear()
    try:
        response = client.post(
            "/auth/register",
            json={
                "email": "admin@example.com",
                "password": "Admin12345",
                "full_name": "Admin User",
                "role": "admin",
            },
        )
    finally:
        get_settings.cache_clear()

    assert response.status_code == 403
    assert response.json()["detail"] == "admin self-registration is disabled"
