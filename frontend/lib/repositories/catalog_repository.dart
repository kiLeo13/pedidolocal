import 'package:pedidolocal/core/api/api_client.dart';
import 'package:pedidolocal/core/api/endpoints.dart';
import 'package:pedidolocal/models/category.dart';
import 'package:pedidolocal/models/product.dart';

class CatalogRepository {
  const CatalogRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Category>> listCategories() async {
    final data = await _apiClient.get(Endpoints.categories);
    return (data as List<dynamic>)
        .map((item) => Category.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<Product>> listProducts() async {
    final data = await _apiClient.get(Endpoints.products);
    return (data as List<dynamic>)
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Category> createCategory({
    required String name,
    String? description,
  }) async {
    final data = await _apiClient.post(
      Endpoints.categories,
      body: {
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
    return Category.fromJson(data as Map<String, dynamic>);
  }

  Future<Product> createProduct({
    required int categoryId,
    required String name,
    String? description,
    required String price,
    required int stock,
    required bool isActive,
    required bool isAlcoholic,
  }) async {
    final data = await _apiClient.post(
      Endpoints.products,
      body: {
        'category_id': categoryId,
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
        'price': price,
        'stock': stock,
        'is_active': isActive,
        'is_alcoholic': isAlcoholic,
      },
    );
    return Product.fromJson(data as Map<String, dynamic>);
  }
}
