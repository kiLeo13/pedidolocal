"""Create initial Pedido Local schema.

Revision ID: 0001_initial
Revises:
Create Date: 2026-05-16 00:00:00
"""

import sqlalchemy as sa
from alembic import op

revision = "0001_initial"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("email", sa.String(length=255), nullable=False),
        sa.Column("full_name", sa.String(length=120), nullable=False),
        sa.Column("hashed_password", sa.String(length=255), nullable=False),
        sa.Column(
            "role",
            sa.Enum("admin", "customer", name="role", native_enum=False, length=20),
            nullable=False,
        ),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("email"),
    )
    op.create_index("ix_users_email", "users", ["email"], unique=False)
    op.create_index("ix_users_role", "users", ["role"], unique=False)

    op.create_table(
        "customer_profiles",
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("phone", sa.String(length=30), nullable=False),
        sa.Column("address_line", sa.String(length=255), nullable=False),
        sa.Column("city", sa.String(length=120), nullable=False),
        sa.Column("birth_date", sa.Date(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("user_id"),
    )
    op.create_index("ix_customer_profiles_city", "customer_profiles", ["city"], unique=False)

    op.create_table(
        "categories",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("name", sa.String(length=80), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("name"),
    )
    op.create_index("ix_categories_is_active", "categories", ["is_active"], unique=False)
    op.create_index("ix_categories_name", "categories", ["name"], unique=False)

    op.create_table(
        "products",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("category_id", sa.Integer(), nullable=False),
        sa.Column("name", sa.String(length=120), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("price", sa.Numeric(10, 2), nullable=False),
        sa.Column("stock", sa.Integer(), nullable=False),
        sa.Column("is_active", sa.Boolean(), nullable=False),
        sa.Column("is_alcoholic", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("price >= 0", name="ck_products_price_non_negative"),
        sa.CheckConstraint("stock >= 0", name="ck_products_stock_non_negative"),
        sa.ForeignKeyConstraint(["category_id"], ["categories.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_products_category_id", "products", ["category_id"], unique=False)
    op.create_index("ix_products_is_active", "products", ["is_active"], unique=False)
    op.create_index("ix_products_name", "products", ["name"], unique=False)

    op.create_table(
        "orders",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("customer_id", sa.Integer(), nullable=False),
        sa.Column(
            "status",
            sa.Enum(
                "pending",
                "confirmed",
                "preparing",
                "out_for_delivery",
                "delivered",
                "canceled",
                name="orderstatus",
                native_enum=False,
                length=30,
            ),
            nullable=False,
        ),
        sa.Column(
            "payment_method",
            sa.Enum(
                "cash",
                "pix",
                "card_machine",
                name="paymentmethod",
                native_enum=False,
                length=30,
            ),
            nullable=False,
        ),
        sa.Column(
            "payment_status",
            sa.Enum(
                "pending",
                "paid",
                "failed",
                "refunded",
                name="paymentstatus",
                native_enum=False,
                length=30,
            ),
            nullable=False,
        ),
        sa.Column("delivery_city", sa.String(length=120), nullable=False),
        sa.Column("delivery_address", sa.String(length=255), nullable=False),
        sa.Column("subtotal", sa.Numeric(10, 2), nullable=False),
        sa.Column("canceled_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("delivered_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("stock_restored", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.CheckConstraint("subtotal >= 0", name="ck_orders_subtotal_non_negative"),
        sa.ForeignKeyConstraint(["customer_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_orders_customer_id", "orders", ["customer_id"], unique=False)
    op.create_index("ix_orders_payment_status", "orders", ["payment_status"], unique=False)
    op.create_index("ix_orders_status", "orders", ["status"], unique=False)

    op.create_table(
        "order_items",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("order_id", sa.Integer(), nullable=False),
        sa.Column("product_id", sa.Integer(), nullable=False),
        sa.Column("product_name_snapshot", sa.String(length=120), nullable=False),
        sa.Column("unit_price", sa.Numeric(10, 2), nullable=False),
        sa.Column("quantity", sa.Integer(), nullable=False),
        sa.Column("line_total", sa.Numeric(10, 2), nullable=False),
        sa.CheckConstraint("line_total >= 0", name="ck_order_items_line_total_non_negative"),
        sa.CheckConstraint("quantity > 0", name="ck_order_items_quantity_positive"),
        sa.CheckConstraint("unit_price >= 0", name="ck_order_items_unit_price_non_negative"),
        sa.ForeignKeyConstraint(["order_id"], ["orders.id"]),
        sa.ForeignKeyConstraint(["product_id"], ["products.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_order_items_order_id", "order_items", ["order_id"], unique=False)
    op.create_index("ix_order_items_product_id", "order_items", ["product_id"], unique=False)

    op.create_table(
        "audit_logs",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("actor_user_id", sa.Integer(), nullable=True),
        sa.Column("action", sa.String(length=80), nullable=False),
        sa.Column("entity_type", sa.String(length=80), nullable=False),
        sa.Column("entity_id", sa.String(length=80), nullable=True),
        sa.Column("request_id", sa.String(length=36), nullable=False),
        sa.Column("before", sa.JSON(), nullable=True),
        sa.Column("after", sa.JSON(), nullable=True),
        sa.Column("log_metadata", sa.JSON(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["actor_user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_audit_logs_action", "audit_logs", ["action"], unique=False)
    op.create_index("ix_audit_logs_actor_user_id", "audit_logs", ["actor_user_id"], unique=False)
    op.create_index("ix_audit_logs_entity_id", "audit_logs", ["entity_id"], unique=False)
    op.create_index("ix_audit_logs_entity_type", "audit_logs", ["entity_type"], unique=False)
    op.create_index("ix_audit_logs_request_id", "audit_logs", ["request_id"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_audit_logs_request_id", table_name="audit_logs")
    op.drop_index("ix_audit_logs_entity_type", table_name="audit_logs")
    op.drop_index("ix_audit_logs_entity_id", table_name="audit_logs")
    op.drop_index("ix_audit_logs_actor_user_id", table_name="audit_logs")
    op.drop_index("ix_audit_logs_action", table_name="audit_logs")
    op.drop_table("audit_logs")
    op.drop_index("ix_order_items_product_id", table_name="order_items")
    op.drop_index("ix_order_items_order_id", table_name="order_items")
    op.drop_table("order_items")
    op.drop_index("ix_orders_status", table_name="orders")
    op.drop_index("ix_orders_payment_status", table_name="orders")
    op.drop_index("ix_orders_customer_id", table_name="orders")
    op.drop_table("orders")
    op.drop_index("ix_products_name", table_name="products")
    op.drop_index("ix_products_is_active", table_name="products")
    op.drop_index("ix_products_category_id", table_name="products")
    op.drop_table("products")
    op.drop_index("ix_categories_name", table_name="categories")
    op.drop_index("ix_categories_is_active", table_name="categories")
    op.drop_table("categories")
    op.drop_index("ix_customer_profiles_city", table_name="customer_profiles")
    op.drop_table("customer_profiles")
    op.drop_index("ix_users_role", table_name="users")
    op.drop_index("ix_users_email", table_name="users")
    op.drop_table("users")
