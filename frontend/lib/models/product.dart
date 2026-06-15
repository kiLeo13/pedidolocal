import 'package:pedidolocal/core/formatters.dart';

class Product {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final double price;
  final int stock;
  final bool isActive;
  final bool isAlcoholic;
  final String createdAt;
  final String updatedAt;

  const Product({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    required this.stock,
    required this.isActive,
    required this.isAlcoholic,
    required this.createdAt,
    required this.updatedAt,
  });

  String get formattedPrice => AppFormatters.currency(price);

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: double.parse(json['price'].toString()),
      stock: json['stock'] as int,
      isActive: json['is_active'] as bool,
      isAlcoholic: json['is_alcoholic'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price.toStringAsFixed(2),
      'stock': stock,
      'is_active': isActive,
      'is_alcoholic': isAlcoholic,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
