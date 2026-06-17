import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pedidolocal/core/api/api_client.dart';
import 'package:pedidolocal/core/token_storage.dart';
import 'package:pedidolocal/providers/auth_provider.dart';
import 'package:pedidolocal/providers/catalog_provider.dart';
import 'package:pedidolocal/repositories/auth_repository.dart';
import 'package:pedidolocal/repositories/catalog_repository.dart';
import 'package:pedidolocal/screens/admin/admin_product_screen.dart';
import 'package:provider/provider.dart';

import 'test_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('admin can create a category and product from the UI', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    var createdCategory = false;
    var createdProduct = false;
    final apiClient = ApiClient(
      baseUrl: 'http://api.test',
      httpClient: MockClient((request) async {
        if (request.url.path == '/auth/token') {
          return http.Response(
            jsonEncode({'access_token': 'admin-token', 'token_type': 'bearer'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/auth/me') {
          return http.Response(
            jsonEncode(userJson(role: 'admin')),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/categories' && request.method == 'GET') {
          return http.Response(
            jsonEncode(<Map<String, dynamic>>[]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/products' && request.method == 'GET') {
          return http.Response(
            jsonEncode(<Map<String, dynamic>>[]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/categories' && request.method == 'POST') {
          createdCategory = true;
          expect(jsonDecode(request.body), {'name': 'Bebidas'});
          return http.Response(
            jsonEncode(categoryJson(id: 2, name: 'Bebidas')),
            201,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/products' && request.method == 'POST') {
          createdProduct = true;
          expect(jsonDecode(request.body), {
            'category_id': 2,
            'name': 'Suco',
            'price': '7.50',
            'stock': 5,
            'is_active': true,
            'is_alcoholic': false,
          });
          return http.Response(
            jsonEncode(
              productJson(id: 20, categoryId: 2, name: 'Suco', price: '7.50'),
            ),
            201,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('not found', 404);
      }),
    );
    final authProvider = AuthProvider(
      repository: AuthRepository(
        apiClient: apiClient,
        tokenStorage: const TokenStorage(),
      ),
    );
    await authProvider.login('admin@example.com', 'Admin12345');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider(
            create: (_) =>
                CatalogProvider(repository: CatalogRepository(apiClient)),
          ),
        ],
        child: const MaterialApp(home: AdminProductScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome da categoria'),
      'Bebidas',
    );
    await tester.tap(find.text('Criar categoria'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome do produto'),
      'Suco',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Preco'), '7,5');
    await tester.enterText(find.widgetWithText(TextFormField, 'Estoque'), '5');
    await tester.tap(find.text('Salvar produto'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(createdCategory, isTrue);
    expect(createdProduct, isTrue);
  });
}
