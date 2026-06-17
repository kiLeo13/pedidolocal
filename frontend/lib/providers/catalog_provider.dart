import 'package:flutter/foundation.dart' hide Category;
import 'package:pedidolocal/core/api/api_exceptions.dart';
import 'package:pedidolocal/models/category.dart';
import 'package:pedidolocal/models/product.dart';
import 'package:pedidolocal/repositories/catalog_repository.dart';

class CatalogProvider extends ChangeNotifier {
  CatalogProvider({required this.repository});

  final CatalogRepository repository;

  List<Category> _categories = [];
  List<Product> _products = [];
  int? _selectedCategoryId;
  String _searchTerm = '';
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => List.unmodifiable(_categories);
  List<Product> get products => List.unmodifiable(_products);
  int? get selectedCategoryId => _selectedCategoryId;
  String get searchTerm => _searchTerm;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLoaded => _products.isNotEmpty || _categories.isNotEmpty;

  List<Product> get visibleProducts {
    return _products
        .where((product) {
          final matchesCategory =
              _selectedCategoryId == null ||
              product.categoryId == _selectedCategoryId;
          final matchesSearch =
              _searchTerm.isEmpty ||
              product.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
              (product.description ?? '').toLowerCase().contains(
                _searchTerm.toLowerCase(),
              );
          return matchesCategory && matchesSearch;
        })
        .toList(growable: false);
  }

  String? categoryNameFor(int id) {
    for (final category in _categories) {
      if (category.id == id) {
        return category.name;
      }
    }
    return null;
  }

  void selectCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void updateSearch(String value) {
    _searchTerm = value.trim();
    notifyListeners();
  }

  Future<void> loadCatalog() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _categories = await repository.listCategories();
      _products = await repository.listProducts();
    } on ApiException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Erro ao carregar catalogo.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Category?> createCategory({
    required String name,
    String? description,
  }) async {
    Category? category;
    await _runMutation(() async {
      category = await repository.createCategory(
        name: name,
        description: description,
      );
      _categories = [..._categories, category!]
        ..sort((left, right) => left.name.compareTo(right.name));
    });
    return category;
  }

  Future<Product?> createProduct({
    required int categoryId,
    required String name,
    String? description,
    required String price,
    required int stock,
    required bool isActive,
    required bool isAlcoholic,
  }) async {
    Product? product;
    await _runMutation(() async {
      product = await repository.createProduct(
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        stock: stock,
        isActive: isActive,
        isAlcoholic: isAlcoholic,
      );
      _products = [..._products, product!]
        ..sort((left, right) => left.name.compareTo(right.name));
    });
    return product;
  }

  Future<void> _runMutation(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
    } on ApiException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Erro ao salvar catalogo.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
