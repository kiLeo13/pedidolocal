from fastapi.testclient import TestClient

from tests.conftest import create_category


def test_registration_rejects_weak_password_invalid_phone_and_future_birth_date(
    client: TestClient,
) -> None:
    base_payload = {
        "email": "validation@example.com",
        "password": "Customer12345",
        "full_name": "Validation User",
        "phone": "11999999999",
        "address_line": "Main Street, 100",
        "city": "Pedido Local",
        "birth_date": "1990-01-01",
    }

    weak_password = client.post(
        "/auth/register",
        json={**base_payload, "password": "password"},
    )
    assert weak_password.status_code == 422

    invalid_phone = client.post(
        "/auth/register",
        json={**base_payload, "phone": "phone-number"},
    )
    assert invalid_phone.status_code == 422

    future_birth_date = client.post(
        "/auth/register",
        json={**base_payload, "birth_date": "2999-01-01"},
    )
    assert future_birth_date.status_code == 422


def test_catalog_rejects_oversized_and_unsafe_product_data(
    client: TestClient,
    admin_headers: dict[str, str],
) -> None:
    category = create_category(client, admin_headers)

    huge_name = client.post(
        "/products",
        json={
            "category_id": category["id"],
            "name": "x" * 121,
            "description": "Too long",
            "price": "10.00",
            "stock": 1,
            "is_active": True,
            "is_alcoholic": False,
        },
        headers=admin_headers,
    )
    assert huge_name.status_code == 422

    control_character = client.post(
        "/products",
        json={
            "category_id": category["id"],
            "name": "Unsafe\u0001Name",
            "description": "Unsafe",
            "price": "10.00",
            "stock": 1,
            "is_active": True,
            "is_alcoholic": False,
        },
        headers=admin_headers,
    )
    assert control_character.status_code == 422

    excessive_price = client.post(
        "/products",
        json={
            "category_id": category["id"],
            "name": "Expensive Product",
            "description": "Too expensive",
            "price": "100000.00",
            "stock": 1,
            "is_active": True,
            "is_alcoholic": False,
        },
        headers=admin_headers,
    )
    assert excessive_price.status_code == 422

    excessive_stock = client.post(
        "/products",
        json={
            "category_id": category["id"],
            "name": "Warehouse Product",
            "description": "Too many units",
            "price": "10.00",
            "stock": 100001,
            "is_active": True,
            "is_alcoholic": False,
        },
        headers=admin_headers,
    )
    assert excessive_stock.status_code == 422


def test_request_body_size_limit_returns_413(client: TestClient) -> None:
    response = client.post("/auth/register", content=b"x" * 1_048_577)

    assert response.status_code == 413
    assert response.json()["detail"] == "request body is too large"
