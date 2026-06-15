import 'package:pedidolocal/core/api/api_client.dart';
import 'package:pedidolocal/core/api/endpoints.dart';
import 'package:pedidolocal/models/cart_item.dart';
import 'package:pedidolocal/models/order.dart';

class OrderRepository {
  const OrderRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Order>> listOrders() async {
    final data = await _apiClient.get(Endpoints.orders);
    return (data as List<dynamic>)
        .map((item) => Order.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Order> getOrder(int id) async {
    final data = await _apiClient.get(Endpoints.order(id));
    return Order.fromJson(data as Map<String, dynamic>);
  }

  Future<Order> createOrder({
    required List<CartItem> items,
    required String paymentMethod,
    required String deliveryCity,
    required String deliveryAddress,
  }) async {
    final body = <String, dynamic>{
      'items': items
          .map(
            (item) => {
              'product_id': item.product.id,
              'quantity': item.quantity,
            },
          )
          .toList(growable: false),
      'payment_method': paymentMethod,
      'delivery_city': deliveryCity,
      'delivery_address': deliveryAddress,
    };
    final data = await _apiClient.post(Endpoints.orders, body: body);
    return Order.fromJson(data as Map<String, dynamic>);
  }

  Future<Order> cancelOrder(int id) async {
    final data = await _apiClient.post(Endpoints.cancelOrder(id));
    return Order.fromJson(data as Map<String, dynamic>);
  }
}
