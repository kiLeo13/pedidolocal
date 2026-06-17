import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pedidolocal/core/api/api_client.dart';
import 'package:pedidolocal/core/token_storage.dart';
import 'package:pedidolocal/models/cart_item.dart';
import 'package:pedidolocal/models/product.dart';
import 'package:pedidolocal/repositories/auth_repository.dart';
import 'package:pedidolocal/repositories/catalog_repository.dart';
import 'package:pedidolocal/repositories/order_repository.dart';

import 'test_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

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

  test(
    'catalog repository sends admin category and product payloads',
    () async {
      final apiClient = ApiClient(
        baseUrl: 'http://api.test',
        httpClient: MockClient((request) async {
          if (request.url.path == '/categories' && request.method == 'POST') {
            expect(jsonDecode(request.body), {
              'name': 'Bebidas',
              'description': 'Bebidas frias',
            });
            return http.Response(
              jsonEncode(categoryJson(id: 2, name: 'Bebidas')),
              201,
              headers: {'content-type': 'application/json'},
            );
          }
          if (request.url.path == '/products' && request.method == 'POST') {
            expect(jsonDecode(request.body), {
              'category_id': 2,
              'name': 'Suco',
              'description': 'Suco natural',
              'price': '7.50',
              'stock': 5,
              'is_active': true,
              'is_alcoholic': false,
            });
            return http.Response(
              jsonEncode(productJson(id: 20, categoryId: 2, name: 'Suco')),
              201,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response('not found', 404);
        }),
      );
      final repository = CatalogRepository(apiClient);

      final category = await repository.createCategory(
        name: 'Bebidas',
        description: 'Bebidas frias',
      );
      final product = await repository.createProduct(
        categoryId: category.id,
        name: 'Suco',
        description: 'Suco natural',
        price: '7.50',
        stock: 5,
        isActive: true,
        isAlcoholic: false,
      );

      expect(category.name, 'Bebidas');
      expect(product.name, 'Suco');
    },
  );

  test(
    'auth repository sends selected admin role during registration',
    () async {
      final apiClient = ApiClient(
        baseUrl: 'http://api.test',
        httpClient: MockClient((request) async {
          if (request.url.path == '/auth/register') {
            expect(request.method, 'POST');
            expect(jsonDecode(request.body), {
              'email': 'admin@example.com',
              'password': 'Admin12345',
              'full_name': 'Admin Teste',
              'role': 'admin',
            });
            return http.Response(
              jsonEncode(userJson(role: 'admin')),
              201,
              headers: {'content-type': 'application/json'},
            );
          }
          if (request.url.path == '/auth/token') {
            expect(request.bodyFields['username'], 'admin@example.com');
            return http.Response(
              jsonEncode({
                'access_token': 'admin-token',
                'token_type': 'bearer',
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          if (request.url.path == '/auth/me') {
            expect(request.headers['authorization'], 'Bearer admin-token');
            return http.Response(
              jsonEncode(userJson(role: 'admin')),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response('not found', 404);
        }),
      );
      final repository = AuthRepository(
        apiClient: apiClient,
        tokenStorage: const TokenStorage(),
      );

      final user = await repository.register(
        email: 'admin@example.com',
        password: 'Admin12345',
        fullName: 'Admin Teste',
        role: 'admin',
      );

      expect(user.isAdmin, isTrue);
      expect(user.profile, isNull);
    },
  );

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
