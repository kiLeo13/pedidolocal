import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pedidolocal/core/api/api_client.dart';
import 'package:pedidolocal/models/cart_item.dart';
import 'package:pedidolocal/models/product.dart';
import 'package:pedidolocal/repositories/catalog_repository.dart';
import 'package:pedidolocal/repositories/order_repository.dart';

import 'test_data.dart';

void main() {
  test('catalog repository parses categories and products', () async {
    final apiClient = ApiClient(
      baseUrl: 'http://api.test',
      httpClient: MockClient((request) async {
        if (request.url.path == '/categories') {
          return http.Response(
            jsonEncode([categoryJson(id: 1, name: 'Cafes')]),
            200,
          );
        }
        if (request.url.path == '/products') {
          return http.Response(
            jsonEncode([
              productJson(id: 10, categoryId: 1, name: 'Cappuccino'),
            ]),
            200,
          );
        }
        return http.Response('not found', 404);
      }),
    );
    final repository = CatalogRepository(apiClient);

    final categories = await repository.listCategories();
    final products = await repository.listProducts();

    expect(categories.single.name, 'Cafes');
    expect(products.single.name, 'Cappuccino');
  });

  test('order repository sends backend order payload', () async {
    final apiClient = ApiClient(
      baseUrl: 'http://api.test',
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/orders');
        expect(jsonDecode(request.body), {
          'items': [
            {'product_id': 10, 'quantity': 2},
          ],
          'payment_method': 'pix',
          'delivery_city': 'Pedido Local',
          'delivery_address': 'Rua Teste, 100',
        });
        return http.Response(
          jsonEncode(orderJson()),
          201,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    final repository = OrderRepository(apiClient);

    final order = await repository.createOrder(
      items: [
        CartItem(
          product: Product.fromJson(
            productJson(id: 10, categoryId: 1, name: 'Cappuccino'),
          ),
          quantity: 2,
        ),
      ],
      paymentMethod: 'pix',
      deliveryCity: 'Pedido Local',
      deliveryAddress: 'Rua Teste, 100',
    );

    expect(order.id, 99);
    expect(order.items.single.quantity, 2);
  });
}
