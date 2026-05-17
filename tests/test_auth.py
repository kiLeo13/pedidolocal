from fastapi.testclient import TestClient

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
