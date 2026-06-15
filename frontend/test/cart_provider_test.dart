import 'package:flutter_test/flutter_test.dart';
import 'package:pedidolocal/models/product.dart';
import 'package:pedidolocal/providers/cart_provider.dart';

void main() {
  test('cart provider adds, increments, decrements, and clears items', () {
    final cart = CartProvider();
    const product = Product(
      id: 1,
      categoryId: 1,
      name: 'Cappuccino',
      price: 3.99,
      stock: 10,
      isActive: true,
      isAlcoholic: false,
      createdAt: '2026-06-14T00:00:00Z',
      updatedAt: '2026-06-14T00:00:00Z',
    );

    cart.add(product);
    cart.increment(product);
    cart.addQuantity(product, 3);
    cart.addQuantity(product, 0);

    expect(cart.itemCount, 5);
    expect(cart.items.single.quantity, 5);
    expect(cart.subtotal, closeTo(19.95, 0.001));

    cart.decrement(product);

    expect(cart.itemCount, 4);
    expect(cart.items.single.quantity, 4);

    cart.decrement(product);
    cart.decrement(product);
    cart.decrement(product);

    expect(cart.itemCount, 1);

    cart.decrement(product);

    expect(cart.isEmpty, isTrue);

    cart.add(product);
    cart.clear();

    expect(cart.isEmpty, isTrue);
  });
}
