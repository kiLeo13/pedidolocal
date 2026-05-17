from fastapi.testclient import TestClient

from tests.conftest import create_category, create_product, login_headers, register_customer


def test_audit_logs_critical_operations_without_secrets(
    client: TestClient,
    admin_headers: dict[str, str],
) -> None:
    register_customer(client)
    customer_headers = login_headers(client, "customer@example.com", "Customer12345")
    denied = client.post(
        "/categories",
        json={"name": "Denied", "description": "Denied"},
        headers=customer_headers,
    )
    assert denied.status_code == 403

    category = create_category(client, admin_headers, name="Juices")
    product = create_product(client, admin_headers, category_id=category["id"], name="Apple Juice")
    order_response = client.post(
        "/orders",
        json={
            "items": [{"product_id": product["id"], "quantity": 1}],
            "payment_method": "pix",
            "delivery_city": "Pedido Local",
            "delivery_address": "Main Street, 100",
        },
        headers=customer_headers,
    )
    assert order_response.status_code == 201

    logs_response = client.get("/audit-logs", headers=admin_headers)

    assert logs_response.status_code == 200
    logs = logs_response.json()
    actions = {log["action"] for log in logs}
    assert {
        "auth.registered",
        "auth.login_success",
        "authorization.denied",
        "category.created",
        "product.created",
        "order.created",
    }.issubset(actions)

    flattened = str(logs).lower()
    assert "customer12345" not in flattened
    assert "hashed_password" not in flattened
    assert "access_token" not in flattened
