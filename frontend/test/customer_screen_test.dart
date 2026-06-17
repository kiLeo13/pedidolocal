import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pedidolocal/core/api/api_client.dart';
import 'package:pedidolocal/core/routes.dart';
import 'package:pedidolocal/core/token_storage.dart';
import 'package:pedidolocal/models/order.dart';
import 'package:pedidolocal/models/product.dart';
import 'package:pedidolocal/providers/auth_provider.dart';
import 'package:pedidolocal/providers/cart_provider.dart';
import 'package:pedidolocal/providers/catalog_provider.dart';
import 'package:pedidolocal/providers/order_provider.dart';
import 'package:pedidolocal/repositories/auth_repository.dart';
import 'package:pedidolocal/repositories/catalog_repository.dart';
import 'package:pedidolocal/repositories/order_repository.dart';
import 'package:pedidolocal/screens/cart/cart_screen.dart';
import 'package:pedidolocal/screens/home/home_screen.dart';
import 'package:pedidolocal/screens/orders/order_tracking_screen.dart';
import 'package:pedidolocal/screens/profile/profile_screen.dart';
import 'package:provider/provider.dart';

import 'test_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('home screen renders loaded catalog products', (tester) async {
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

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(
            create: (_) =>
                CatalogProvider(repository: CatalogRepository(apiClient)),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cappuccino'), findsOneWidget);
    expect(find.text('Cafes'), findsWidgets);
  });

  testWidgets('home screen renders catalog error state', (tester) async {
    final apiClient = ApiClient(
      baseUrl: 'http://api.test',
      httpClient: MockClient((_) async => http.Response('server error', 500)),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(
            create: (_) =>
                CatalogProvider(repository: CatalogRepository(apiClient)),
          ),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nao foi possivel carregar o catalogo.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('checkout submits cart order and opens tracking', (tester) async {
    final apiClient = ApiClient(
      baseUrl: 'http://api.test',
      httpClient: MockClient((request) async {
        if (request.url.path == '/auth/token') {
          return http.Response(
            jsonEncode({'access_token': 'token-123', 'token_type': 'bearer'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/auth/me') {
          return http.Response(
            jsonEncode(userJson()),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/orders' && request.method == 'POST') {
          expect(jsonDecode(request.body)['items'], [
            {'product_id': 10, 'quantity': 2},
          ]);
          return http.Response(
            jsonEncode(orderJson(status: 'pending')),
            201,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/orders/99') {
          return http.Response(
            jsonEncode(orderJson(status: 'confirmed')),
            200,
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
    await authProvider.login('customer@example.com', 'Customer123');
    final cartProvider = CartProvider()
      ..addQuantity(
        Product.fromJson(
          productJson(id: 10, categoryId: 1, name: 'Cappuccino'),
        ),
        2,
      );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
          ChangeNotifierProvider(
            create: (_) =>
                OrderProvider(repository: OrderRepository(apiClient)),
          ),
        ],
        child: MaterialApp(
          home: const CartScreen(),
          onGenerateRoute: RouteGenerator.onGenerateRoute,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.textContaining('Pedir'));
    await tester.pumpAndSettle();

    expect(cartProvider.isEmpty, isTrue);
    expect(find.text('Pedido #99'), findsOneWidget);
    expect(find.text('Pedido confirmado'), findsOneWidget);
  });

  testWidgets('order tracking displays timeline and order summary', (
    tester,
  ) async {
    final apiClient = ApiClient(
      baseUrl: 'http://api.test',
      httpClient: MockClient((request) async {
        if (request.url.path == '/orders/99') {
          return http.Response(
            jsonEncode(orderJson(status: 'out_for_delivery')),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('not found', 404);
      }),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => OrderProvider(repository: OrderRepository(apiClient)),
        child: MaterialApp(
          home: OrderTrackingScreen(
            order: Order.fromJson(orderJson(status: 'out_for_delivery')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chega em breve'), findsOneWidget);
    expect(find.text('Entrega'), findsOneWidget);
    expect(find.text('2x Cappuccino'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Atualizar pedido'),
      180,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Atualizar pedido'), findsOneWidget);
  });

  testWidgets('profile logout clears auth state and returns to login', (
    tester,
  ) async {
    final apiClient = ApiClient(
      baseUrl: 'http://api.test',
      httpClient: MockClient((request) async {
        if (request.url.path == '/auth/token') {
          return http.Response(
            jsonEncode({'access_token': 'token-123', 'token_type': 'bearer'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.url.path == '/auth/me') {
          return http.Response(
            jsonEncode(userJson()),
            200,
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
    await authProvider.login('customer@example.com', 'Customer123');

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: MaterialApp(
          home: const ProfileScreen(),
          onGenerateRoute: RouteGenerator.onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cliente Teste'), findsOneWidget);

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    expect(authProvider.isAuthenticated, isFalse);
    expect(find.text('Acesso do cliente'), findsOneWidget);
  });
}
