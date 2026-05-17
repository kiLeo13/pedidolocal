from collections.abc import Generator
from decimal import Decimal
from pathlib import Path

import pytest
from alembic import command
from alembic.config import Config
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session, sessionmaker

from app.db.session import create_db_engine, get_db
from app.main import create_app
from app.services.auth import create_admin_user


@pytest.fixture()
def client(tmp_path: Path) -> Generator[TestClient]:
    database_path = tmp_path / "test.db"
    database_url = f"sqlite:///{database_path.as_posix()}"
    alembic_cfg = Config("alembic.ini")
    alembic_cfg.set_main_option("sqlalchemy.url", database_url)
    command.upgrade(alembic_cfg, "head")

    engine = create_db_engine(database_url)
    testing_session_local = sessionmaker(
        bind=engine,
        autoflush=False,
        autocommit=False,
        future=True,
    )

    def override_get_db() -> Generator[Session]:
        db = testing_session_local()
        try:
            yield db
        finally:
            db.close()

    app = create_app()
    app.dependency_overrides[get_db] = override_get_db
    app.state.testing_session_local = testing_session_local

    with TestClient(app) as test_client:
        yield test_client

    app.dependency_overrides.clear()
    engine.dispose()


@pytest.fixture()
def db_session(client: TestClient) -> Generator[Session]:
    session_factory = client.app.state.testing_session_local
    with session_factory() as db:
        yield db


@pytest.fixture()
def admin_headers(client: TestClient, db_session: Session) -> dict[str, str]:
    create_admin_user(
        db_session,
        email="admin@example.com",
        password="Admin12345",
        full_name="System Admin",
    )
    return login_headers(client, "admin@example.com", "Admin12345")


def login_headers(client: TestClient, email: str, password: str) -> dict[str, str]:
    response = client.post("/auth/token", data={"username": email, "password": password})
    assert response.status_code == 200, response.text
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


def register_customer(
    client: TestClient,
    *,
    email: str = "customer@example.com",
    password: str = "Customer12345",
    birth_date: str | None = "1990-01-01",
    city: str = "Pedido Local",
) -> dict:
    payload = {
        "email": email,
        "password": password,
        "full_name": "Customer User",
        "phone": "11999999999",
        "address_line": "Main Street, 100",
        "city": city,
        "birth_date": birth_date,
    }
    response = client.post("/auth/register", json=payload)
    assert response.status_code == 201, response.text
    return response.json()


def create_category(
    client: TestClient,
    admin_headers: dict[str, str],
    *,
    name: str = "Beverages",
) -> dict:
    response = client.post(
        "/categories",
        json={"name": name, "description": f"{name} category"},
        headers=admin_headers,
    )
    assert response.status_code == 201, response.text
    return response.json()


def create_product(
    client: TestClient,
    admin_headers: dict[str, str],
    *,
    category_id: int,
    name: str = "Orange Juice",
    price: Decimal = Decimal("12.50"),
    stock: int = 10,
    is_alcoholic: bool = False,
    is_active: bool = True,
) -> dict:
    response = client.post(
        "/products",
        json={
            "category_id": category_id,
            "name": name,
            "description": f"{name} description",
            "price": str(price),
            "stock": stock,
            "is_active": is_active,
            "is_alcoholic": is_alcoholic,
        },
        headers=admin_headers,
    )
    assert response.status_code == 201, response.text
    return response.json()
