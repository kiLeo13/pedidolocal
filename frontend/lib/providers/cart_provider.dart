import 'package:flutter/foundation.dart';
import 'package:pedidolocal/models/cart_item.dart';
import 'package:pedidolocal/models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (total, item) => total + item.quantity);
  double get subtotal =>
      _items.fold(0.0, (total, item) => total + item.lineTotal);

  void add(Product product) {
    addQuantity(product, 1);
  }

  void addQuantity(Product product, int quantity) {
    if (quantity <= 0) {
      return;
    }
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index == -1) {
      _items.add(CartItem(product: product, quantity: quantity));
    } else {
      _items[index].quantity += quantity;
    }
    notifyListeners();
  }

  void increment(Product product) {
    add(product);
  }

  void decrement(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index == -1) {
      return;
    }
    final item = _items[index];
    if (item.quantity <= 1) {
      _items.removeAt(index);
    } else {
      item.quantity -= 1;
    }
    notifyListeners();
  }

  void remove(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
