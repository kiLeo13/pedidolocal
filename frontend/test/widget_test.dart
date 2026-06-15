import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pedidolocal/main.dart';
import 'package:pedidolocal/models/product.dart';
import 'package:pedidolocal/providers/cart_provider.dart';
import 'package:pedidolocal/screens/product/product_detail_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('renders the Pedido Local splash screen', (tester) async {
    await tester.pumpWidget(const PedidoLocalApp());

    expect(find.text('Pedido Local'), findsWidgets);
    expect(find.text('Comecar agora'), findsOneWidget);
  });

  testWidgets('product detail adds selected quantity to cart', (tester) async {
    final cart = CartProvider();
    const product = Product(
      id: 1,
      categoryId: 1,
      name: 'Cappuccino',
      description: 'Cafe cremoso.',
      price: 3.99,
      stock: 10,
      isActive: true,
      isAlcoholic: false,
      createdAt: '2026-06-14T00:00:00Z',
      updatedAt: '2026-06-14T00:00:00Z',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<CartProvider>.value(
        value: cart,
        child: const MaterialApp(home: ProductDetailScreen(product: product)),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.tap(find.text('Adicionar'));
    await tester.pump();

    expect(cart.itemCount, 2);
    expect(cart.items.single.product, product);
  });
}
