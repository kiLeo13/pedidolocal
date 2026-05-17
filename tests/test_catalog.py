from fastapi.testclient import TestClient

from tests.conftest import create_category, create_product, login_headers, register_customer


def test_catalog_admin_permissions_public_reads_and_soft_delete(
    client: TestClient,
    admin_headers: dict[str, str],
) -> None:
    register_customer(client)
    customer_headers = login_headers(client, "customer@example.com", "Customer12345")

    denied = client.post(
        "/categories",
        json={"name": "Snacks", "description": "Snack food"},
        headers=customer_headers,
    )
    assert denied.status_code == 403

    category = create_category(client, admin_headers, name="Snacks")
    product = create_product(
        client,
        admin_headers,
        category_id=category["id"],
        name="Potato Chips",
        stock=6,
    )

    public_categories = client.get("/categories")
    assert public_categories.status_code == 200
    assert [item["name"] for item in public_categories.json()] == ["Snacks"]

    public_product = client.get(f"/products/{product['id']}")
    assert public_product.status_code == 200
    assert public_product.json()["name"] == "Potato Chips"

    deleted_product = client.delete(f"/products/{product['id']}", headers=admin_headers)
    assert deleted_product.status_code == 200
    assert deleted_product.json()["is_active"] is False

    hidden_product = client.get(f"/products/{product['id']}")
    assert hidden_product.status_code == 404
    assert client.get("/products").json() == []


def test_product_requires_active_category(
    client: TestClient,
    admin_headers: dict[str, str],
) -> None:
    category = create_category(client, admin_headers, name="Desserts")
    client.delete(f"/categories/{category['id']}", headers=admin_headers)

    response = client.post(
        "/products",
        json={
            "category_id": category["id"],
            "name": "Cake",
            "description": "Chocolate cake",
            "price": "20.00",
            "stock": 3,
            "is_active": True,
            "is_alcoholic": False,
        },
        headers=admin_headers,
    )

    assert response.status_code == 404
