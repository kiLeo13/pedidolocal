from decimal import Decimal

from fastapi.testclient import TestClient

from tests.conftest import create_category, create_product, login_headers, register_customer


def decimal_from_json(value: str | int | float) -> Decimal:
    return Decimal(str(value))


def create_order_payload(product_id: int, *, quantity: int = 2, city: str = "Pedido Local") -> dict:
    return {
        "items": [{"product_id": product_id, "quantity": quantity}],
        "payment_method": "pix",
        "delivery_city": city,
        "delivery_address": "Main Street, 100",
    }


def test_order_creation_total_stock_snapshot_and_cancel(
    client: TestClient,
    admin_headers: dict[str, str],
) -> None:
    category = create_category(client, admin_headers)
    product = create_product(
        client,
        admin_headers,
        category_id=category["id"],
        name="Orange Juice",
        price=Decimal("12.50"),
        stock=10,
    )
    register_customer(client)
    customer_headers = login_headers(client, "customer@example.com", "Customer12345")

    response = client.post(
        "/orders",
        json=create_order_payload(product["id"], quantity=2),
        headers=customer_headers,
    )

    assert response.status_code == 201, response.text
    order = response.json()
    assert decimal_from_json(order["subtotal"]) == Decimal("25.00")
    assert order["items"][0]["product_name_snapshot"] == "Orange Juice"
    assert decimal_from_json(order["items"][0]["unit_price"]) == Decimal("12.50")
    assert client.get(f"/products/{product['id']}").json()["stock"] == 8

    cancel = client.post(f"/orders/{order['id']}/cancel", headers=customer_headers)
    assert cancel.status_code == 200
    assert cancel.json()["status"] == "canceled"
    assert cancel.json()["stock_restored"] is True
    assert client.get(f"/products/{product['id']}").json()["stock"] == 10

    second_cancel = client.post(f"/orders/{order['id']}/cancel", headers=customer_headers)
    assert second_cancel.status_code == 200
    assert client.get(f"/products/{product['id']}").json()["stock"] == 10


def test_order_rejections_do_not_corrupt_stock(
    client: TestClient,
    admin_headers: dict[str, str],
) -> None:
    category = create_category(client, admin_headers)
    first_product = create_product(
        client,
        admin_headers,
        category_id=category["id"],
        name="Juice",
        stock=5,
    )
    second_product = create_product(
        client,
        admin_headers,
        category_id=category["id"],
        name="Snack",
        stock=1,
    )
    register_customer(client)
    customer_headers = login_headers(client, "customer@example.com", "Customer12345")

    response = client.post(
        "/orders",
        json={
            "items": [
                {"product_id": first_product["id"], "quantity": 2},
                {"product_id": second_product["id"], "quantity": 2},
            ],
            "payment_method": "cash",
            "delivery_city": "Pedido Local",
            "delivery_address": "Main Street, 100",
        },
        headers=customer_headers,
    )

    assert response.status_code == 409
    assert client.get(f"/products/{first_product['id']}").json()["stock"] == 5

    wrong_city = client.post(
        "/orders",
        json=create_order_payload(first_product["id"], city="Another City"),
        headers=customer_headers,
    )
    assert wrong_city.status_code == 400


def test_order_rejects_alcohol_for_underage_customer_and_inactive_products(
    client: TestClient,
    admin_headers: dict[str, str],
) -> None:
    category = create_category(client, admin_headers, name="Drinks")
    alcoholic_product = create_product(
        client,
        admin_headers,
        category_id=category["id"],
        name="Beer",
        stock=4,
        is_alcoholic=True,
    )
    inactive_product = create_product(
        client,
        admin_headers,
        category_id=category["id"],
        name="Inactive Soda",
        stock=4,
    )
    client.delete(f"/products/{inactive_product['id']}", headers=admin_headers)
    register_customer(client, email="young@example.com", birth_date="2012-01-01")
    young_headers = login_headers(client, "young@example.com", "Customer12345")

    alcohol_response = client.post(
        "/orders",
        json=create_order_payload(alcoholic_product["id"]),
        headers=young_headers,
    )
    assert alcohol_response.status_code == 403

    inactive_response = client.post(
        "/orders",
        json=create_order_payload(inactive_product["id"]),
        headers=young_headers,
    )
    assert inactive_response.status_code == 404


def test_order_visibility_admin_status_and_payment_transitions(
    client: TestClient,
    admin_headers: dict[str, str],
) -> None:
    category = create_category(client, admin_headers, name="Vegetables")
    product = create_product(client, admin_headers, category_id=category["id"], name="Tomato")
    register_customer(client, email="first@example.com")
    first_headers = login_headers(client, "first@example.com", "Customer12345")
    register_customer(client, email="second@example.com")
    second_headers = login_headers(client, "second@example.com", "Customer12345")

    created = client.post(
        "/orders",
        json=create_order_payload(product["id"], quantity=1),
        headers=first_headers,
    )
    assert created.status_code == 201
    order_id = created.json()["id"]

    assert client.get(f"/orders/{order_id}", headers=second_headers).status_code == 404
    assert client.get("/orders", headers=second_headers).json() == []
    assert len(client.get("/orders", headers=admin_headers).json()) == 1

    invalid = client.patch(
        f"/orders/{order_id}/status",
        json={"status": "delivered"},
        headers=admin_headers,
    )
    assert invalid.status_code == 409

    confirmed = client.patch(
        f"/orders/{order_id}/status",
        json={"status": "confirmed"},
        headers=admin_headers,
    )
    assert confirmed.status_code == 200
    assert confirmed.json()["status"] == "confirmed"

    paid = client.patch(
        f"/orders/{order_id}/payment",
        json={"payment_status": "paid"},
        headers=admin_headers,
    )
    assert paid.status_code == 200
    assert paid.json()["payment_status"] == "paid"

    invalid_payment = client.patch(
        f"/orders/{order_id}/payment",
        json={"payment_status": "failed"},
        headers=admin_headers,
    )
    assert invalid_payment.status_code == 409
