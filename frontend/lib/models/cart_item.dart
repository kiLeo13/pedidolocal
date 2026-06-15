import 'package:pedidolocal/core/formatters.dart';
import 'package:pedidolocal/models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get lineTotal => product.price * quantity;

  String get formattedLineTotal => AppFormatters.currency(lineTotal);
}
