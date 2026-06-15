import 'package:flutter/foundation.dart';
import 'package:pedidolocal/core/api/api_exceptions.dart';
import 'package:pedidolocal/models/cart_item.dart';
import 'package:pedidolocal/models/order.dart';
import 'package:pedidolocal/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({required this.repository});

  final OrderRepository repository;

  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => List.unmodifiable(_orders);
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setSelectedOrder(Order order) {
    _selectedOrder = order;
    notifyListeners();
  }

  Future<void> loadOrders() async {
    await _run(() async {
      _orders = await repository.listOrders();
    });
  }

  Future<Order?> createOrder({
    required List<CartItem> items,
    required String paymentMethod,
    required String deliveryCity,
    required String deliveryAddress,
  }) async {
    Order? order;
    await _run(() async {
      order = await repository.createOrder(
        items: items,
        paymentMethod: paymentMethod,
        deliveryCity: deliveryCity,
        deliveryAddress: deliveryAddress,
      );
      _selectedOrder = order;
      _orders = [order!, ..._orders];
    });
    return order;
  }

  Future<void> selectOrder(int id) async {
    await _run(() async {
      _selectedOrder = await repository.getOrder(id);
      _upsertOrder(_selectedOrder!);
    });
  }

  Future<void> cancelSelectedOrder() async {
    final order = _selectedOrder;
    if (order == null) {
      return;
    }
    await _run(() async {
      _selectedOrder = await repository.cancelOrder(order.id);
      _upsertOrder(_selectedOrder!);
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
    } on ApiException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Erro ao carregar pedidos.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _upsertOrder(Order order) {
    final index = _orders.indexWhere((item) => item.id == order.id);
    if (index == -1) {
      _orders = [order, ..._orders];
    } else {
      _orders = [
        for (final item in _orders) item.id == order.id ? order : item,
      ];
    }
  }
}
