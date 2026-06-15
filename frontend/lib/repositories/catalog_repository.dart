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
}
