from fastapi.testclient import TestClient


def test_cors_headers_allow_any_origin_on_route_response(client: TestClient) -> None:
    response = client.get("/health", headers={"Origin": "https://example.test"})

    assert response.status_code == 200
    assert response.headers["access-control-allow-origin"] == "https://example.test"
    assert response.headers["access-control-allow-credentials"] == "true"
    assert response.headers["access-control-expose-headers"] == "*"


def test_cors_preflight_allows_any_method_and_headers(client: TestClient) -> None:
    response = client.options(
        "/products",
        headers={
            "Origin": "https://admin.example.test",
            "Access-Control-Request-Method": "POST",
            "Access-Control-Request-Headers": "authorization, content-type, x-request-id",
        },
    )

    assert response.status_code == 200
    assert response.text == "OK"
    assert response.headers["access-control-allow-origin"] == "https://admin.example.test"
    assert response.headers["access-control-allow-credentials"] == "true"
    assert "POST" in response.headers["access-control-allow-methods"]
    allowed_headers = response.headers["access-control-allow-headers"].lower()
    assert "authorization" in allowed_headers
    assert "content-type" in allowed_headers
    assert "x-request-id" in allowed_headers
