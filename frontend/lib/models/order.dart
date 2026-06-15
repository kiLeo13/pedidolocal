import 'package:pedidolocal/core/formatters.dart';

class OrderItem {
  const OrderItem({
    required this.id,
    required this.productId,
    required this.productNameSnapshot,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  final int id;
  final int productId;
  final String productNameSnapshot;
  final double unitPrice;
  final int quantity;
  final double lineTotal;

  String get formattedUnitPrice => AppFormatters.currency(unitPrice);
  String get formattedLineTotal => AppFormatters.currency(lineTotal);

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      productNameSnapshot: json['product_name_snapshot'] as String,
      unitPrice: double.parse(json['unit_price'].toString()),
      quantity: json['quantity'] as int,
      lineTotal: double.parse(json['line_total'].toString()),
    );
  }
}

class Order {
  const Order({
    required this.id,
    required this.customerId,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.deliveryCity,
    required this.deliveryAddress,
    required this.subtotal,
    required this.stockRestored,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    this.canceledAt,
    this.deliveredAt,
  });

  final int id;
  final int customerId;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final String deliveryCity;
  final String deliveryAddress;
  final double subtotal;
  final bool stockRestored;
  final String createdAt;
  final String updatedAt;
  final String? canceledAt;
  final String? deliveredAt;
  final List<OrderItem> items;

  String get formattedSubtotal => AppFormatters.currency(subtotal);

  String get statusLabel {
    return switch (status) {
      'pending' => 'Pendente',
      'confirmed' => 'Confirmado',
      'preparing' => 'Em preparo',
      'out_for_delivery' => 'Saiu para entrega',
      'delivered' => 'Entregue',
      'canceled' => 'Cancelado',
      _ => status,
    };
  }

  String get paymentMethodLabel {
    return switch (paymentMethod) {
      'cash' => 'Dinheiro',
      'pix' => 'Pix',
      'card_machine' => 'Maquina de cartao',
      _ => paymentMethod,
    };
  }

  String get paymentStatusLabel {
    return switch (paymentStatus) {
      'pending' => 'Pendente',
      'paid' => 'Pago',
      'failed' => 'Falhou',
      'refunded' => 'Reembolsado',
      _ => paymentStatus,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      customerId: json['customer_id'] as int,
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      deliveryCity: json['delivery_city'] as String,
      deliveryAddress: json['delivery_address'] as String,
      subtotal: double.parse(json['subtotal'].toString()),
      stockRestored: json['stock_restored'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      canceledAt: json['canceled_at'] as String?,
      deliveredAt: json['delivered_at'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}
