import 'package:flutter/material.dart';
import 'package:pedidolocal/models/order.dart';
import 'package:pedidolocal/models/product.dart';
import 'package:pedidolocal/screens/admin/admin_product_screen.dart';
import 'package:pedidolocal/screens/auth/login_screen.dart';
import 'package:pedidolocal/screens/auth/register_screen.dart';
import 'package:pedidolocal/screens/cart/cart_screen.dart';
import 'package:pedidolocal/screens/home/home_screen.dart';
import 'package:pedidolocal/screens/orders/order_list_screen.dart';
import 'package:pedidolocal/screens/orders/order_tracking_screen.dart';
import 'package:pedidolocal/screens/product/product_detail_screen.dart';
import 'package:pedidolocal/screens/profile/profile_screen.dart';
import 'package:pedidolocal/screens/splash/splash_screen.dart';

abstract final class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String productDetail = '/product';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String orderTracking = '/orders/detail';
  static const String profile = '/profile';
  static const String adminProduct = '/admin/products/new';
}

class RouteGenerator {
  const RouteGenerator._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final page = switch (settings.name) {
      Routes.splash => const SplashScreen(),
      Routes.login => const LoginScreen(),
      Routes.register => const RegisterScreen(),
      Routes.home => const HomeScreen(),
      Routes.productDetail => _productDetail(settings.arguments),
      Routes.cart => const CartScreen(),
      Routes.orders => const OrderListScreen(),
      Routes.orderTracking => _orderTracking(settings.arguments),
      Routes.profile => const ProfileScreen(),
      Routes.adminProduct => const AdminProductScreen(),
      _ => const NotFoundScreen(),
    };

    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        final offset = Tween(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(offset),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 180),
    );
  }

  static Widget _productDetail(Object? arguments) {
    if (arguments is Product) {
      return ProductDetailScreen(product: arguments);
    }
    return const NotFoundScreen();
  }

  static Widget _orderTracking(Object? arguments) {
    if (arguments is Order) {
      return OrderTrackingScreen(order: arguments);
    }
    return const NotFoundScreen();
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagina nao encontrada')),
      body: const Center(
        child: Text('A pagina solicitada nao foi encontrada.'),
      ),
    );
  }
}
