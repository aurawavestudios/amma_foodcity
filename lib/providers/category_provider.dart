// lib/providers/category_provider.dart
import 'package:flutter/foundation.dart';
import '../models/product_category.dart';
import '../services/category_service.dart';
import '../services/shopify_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService;
  List<ProductCategory> _categories = [];
  bool _isLoading = false;
  String? _error;

  CategoryProvider(ShopifyService shopifyService)
      : _categoryService = CategoryService(shopifyService);

  List<ProductCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _categories = await _categoryService.getCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ProductCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  ProductCategory? getCategoryByName(String name) {
    try {
      return _categories.firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}