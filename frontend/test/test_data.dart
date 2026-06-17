Map<String, dynamic> categoryJson({required int id, required String name}) {
  return {
    'id': id,
    'name': name,
    'description': null,
    'is_active': true,
    'created_at': '2026-06-14T00:00:00Z',
    'updated_at': '2026-06-14T00:00:00Z',
  };
}

Map<String, dynamic> productJson({
  required int id,
  required int categoryId,
  required String name,
  String description = 'Produto teste',
  String price = '3.99',
  int stock = 10,
  bool isActive = true,
  bool isAlcoholic = false,
}) {
  return {
    'id': id,
    'category_id': categoryId,
    'name': name,
    'description': description,
    'price': price,
    'stock': stock,
    'is_active': isActive,
    'is_alcoholic': isAlcoholic,
    'created_at': '2026-06-14T00:00:00Z',
    'updated_at': '2026-06-14T00:00:00Z',
  };
}

Map<String, dynamic> userJson({String role = 'customer'}) {
  return {
    'id': 1,
    'email': role == 'admin' ? 'admin@example.com' : 'customer@example.com',
    'full_name': role == 'admin' ? 'Admin Teste' : 'Cliente Teste',
    'role': role,
    'is_active': true,
    'created_at': '2026-06-14T00:00:00Z',
    'profile': role == 'admin'
        ? null
        : {
            'phone': '98999999999',
            'address_line': 'Rua Teste, 100',
            'city': 'Pedido Local',
            'birth_date': '1990-01-01',
          },
  };
}

Map<String, dynamic> orderJson({String status = 'pending'}) {
  return {
    'id': 99,
    'customer_id': 1,
    'status': status,
    'payment_method': 'pix',
    'payment_status': 'pending',
    'delivery_city': 'Pedido Local',
    'delivery_address': 'Rua Teste, 100',
    'subtotal': '7.98',
    'stock_restored': false,
    'created_at': '2026-06-14T00:00:00Z',
    'updated_at': '2026-06-14T00:00:00Z',
    'canceled_at': null,
    'delivered_at': null,
    'items': [
      {
        'id': 1,
        'product_id': 10,
        'product_name_snapshot': 'Cappuccino',
        'unit_price': '3.99',
        'quantity': 2,
        'line_total': '7.98',
      },
    ],
  };
}
