// lib/services/category_service.dart
import '../services/shopify_service.dart';
import '../models/product_category.dart';
import '../models/product.dart';

class CategoryService {
  final ShopifyService _shopifyService;

  CategoryService(this._shopifyService);

  Future<List<ProductCategory>> getCategories() async {
    try {
      // Get categories directly from ShopifyService
      return await _shopifyService.getCollections();
    } catch (e, stackTrace) {
      print('Error loading categories: $e');
      print('Stack trace: $stackTrace');
      // Return empty list instead of throwing to handle the error gracefully
      return [];
    }
  }

  Future<Map<String, List<Product>>> fetchProductsByCategory() async {
    try {
      final result = await _shopifyService.getProducts();
      if (result == null || !result.containsKey('products')) {
        return {};
      }

      final List<dynamic> productList = result['products'] as List<dynamic>;
      final Map<String, List<Product>> categorizedProducts = {};
      
      for (var product in productList) {
        if (product is Product) {
          final category = product.category;
          if (!categorizedProducts.containsKey(category)) {
            categorizedProducts[category] = [];
          }
          categorizedProducts[category]!.add(product);
        }
      }

      return categorizedProducts;
    } catch (e, stackTrace) {
      print('Error fetching categorized products: $e');
      print('Stack trace: $stackTrace');
      return {};
    }
  }

  Future<List<Product>> getProductsByType(String type) async {
    try {
      final result = await _shopifyService.getProducts(
        productType: type,
        first: 20,
        sortKey: 'TITLE',
      );
      
      if (result == null || !result.containsKey('products')) {
        return [];
      }

      final List<dynamic> productList = result['products'] as List<dynamic>;
      return productList
          .whereType<Product>()
          .where((product) => _isValidProduct(product))
          .toList();
    } catch (e, stackTrace) {
      print('Error getting products by type: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<List<Product>> getProductsByCollection(String collectionId) async {
    try {
      final result = await _shopifyService.getProducts(
        collectionId: collectionId,
        first: 20,
        sortKey: 'BEST_SELLING',
      );
      
      if (result == null || !result.containsKey('products')) {
        return [];
      }

      final List<dynamic> productList = result['products'] as List<dynamic>;
      return productList
          .whereType<Product>()
          .where((product) => _isValidProduct(product))
          .toList();
    } catch (e, stackTrace) {
      print('Error getting products by collection: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<List<String>> getSubcategories(String collectionId) async {
    try {
      final subcategories = await _shopifyService.getSubcategoriesForCollection(collectionId);
      return subcategories.where((s) => s.isNotEmpty).toList();
    } catch (e, stackTrace) {
      print('Error getting subcategories: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  bool _isValidProduct(dynamic product) {
    return product is Product && 
           product.id.isNotEmpty && 
           product.name.isNotEmpty;
  }
}