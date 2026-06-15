import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:pedidolocal/core/api/api_client.dart';
import 'package:pedidolocal/core/constants.dart';
import 'package:pedidolocal/core/routes.dart';
import 'package:pedidolocal/core/theme.dart';
import 'package:pedidolocal/core/token_storage.dart';
import 'package:pedidolocal/providers/auth_provider.dart';
import 'package:pedidolocal/providers/cart_provider.dart';
import 'package:pedidolocal/providers/catalog_provider.dart';
import 'package:pedidolocal/providers/order_provider.dart';
import 'package:pedidolocal/repositories/auth_repository.dart';
import 'package:pedidolocal/repositories/catalog_repository.dart';
import 'package:pedidolocal/repositories/order_repository.dart';

void main() {
  runApp(const PedidoLocalApp());
}

class PedidoLocalApp extends StatelessWidget {
  const PedidoLocalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(
          create: (_) => ApiClient(),
          dispose: (_, client) => client.dispose(),
        ),
        Provider<TokenStorage>(create: (_) => const TokenStorage()),
        ProxyProvider2<ApiClient, TokenStorage, AuthRepository>(
          update: (_, apiClient, tokenStorage, _) =>
              AuthRepository(apiClient: apiClient, tokenStorage: tokenStorage),
        ),
        ProxyProvider<ApiClient, CatalogRepository>(
          update: (_, apiClient, _) => CatalogRepository(apiClient),
        ),
        ProxyProvider<ApiClient, OrderRepository>(
          update: (_, apiClient, _) => OrderRepository(apiClient),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) =>
              AuthProvider(repository: context.read<AuthRepository>()),
        ),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<CatalogProvider>(
          create: (context) =>
              CatalogProvider(repository: context.read<CatalogRepository>()),
        ),
        ChangeNotifierProvider<OrderProvider>(
          create: (context) =>
              OrderProvider(repository: context.read<OrderRepository>()),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: Routes.splash,
        onGenerateRoute: RouteGenerator.onGenerateRoute,
      ),
    );
  }
}
