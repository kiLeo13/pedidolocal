import 'package:flutter_test/flutter_test.dart';
import 'package:pedidolocal/models/cart_item.dart';
import 'package:pedidolocal/models/category.dart';
import 'package:pedidolocal/models/order.dart';
import 'package:pedidolocal/models/product.dart';
import 'package:pedidolocal/models/token.dart';
import 'package:pedidolocal/models/user.dart';

import 'test_data.dart';

void main() {
  test('parses token response JSON', () {
    final token = TokenResponse.fromJson({
      'access_token': 'token-123',
      'token_type': 'bearer',
    });

    expect(token.accessToken, 'token-123');
    expect(token.tokenType, 'bearer');
  });

  test('parses user and customer profile JSON', () {
    final user = User.fromJson(userJson());

    expect(user.email, 'customer@example.com');
    expect(user.fullName, 'Cliente Teste');
    expect(user.isCustomer, isTrue);
    expect(user.profile?.addressLine, 'Rua Teste, 100');
    expect(user.toJson()['profile'], isA<Map<String, dynamic>>());
  });

  test('parses category and product JSON', () {
    final category = Category.fromJson(categoryJson(id: 1, name: 'Cafes'));
    final product = Product.fromJson(
      productJson(id: 10, categoryId: 1, name: 'Cappuccino'),
    );

    expect(category.name, 'Cafes');
    expect(category.toJson()['is_active'], isTrue);
    expect(product.name, 'Cappuccino');
    expect(product.formattedPrice, contains('3,99'));
    expect(product.toJson()['price'], '3.99');
  });

  test('cart item exposes formatted line total', () {
    final product = Product.fromJson(
      productJson(id: 10, categoryId: 1, name: 'Cappuccino'),
    );
    final item = CartItem(product: product, quantity: 2);

    expect(item.lineTotal, closeTo(7.98, 0.001));
    expect(item.formattedLineTotal, contains('7,98'));
  });

  test('parses order and order item JSON', () {
    final order = Order.fromJson(orderJson(status: 'out_for_delivery'));

    expect(order.id, 99);
    expect(order.statusLabel, 'Saiu para entrega');
    expect(order.paymentMethodLabel, 'Pix');
    expect(order.paymentStatusLabel, 'Pendente');
    expect(order.items.single.productNameSnapshot, 'Cappuccino');
    expect(order.items.single.formattedLineTotal, contains('7,98'));
  });
}
