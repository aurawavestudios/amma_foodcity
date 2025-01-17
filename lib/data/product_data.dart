// lib/data/product_data.dart
import '../models/product.dart';
import '../services/data_service.dart';

class ProductsData {
  static const Duration _cacheTimeout = Duration(minutes: 5);

  static Future<void> loadProducts() async {
    if (!DataService.isInitialized) {
      throw Exception('DataService not initialized');
    }
    
    try {
      // Check if cache is still valid
      final lastFetchStr = DataService.cacheBox.get('lastProductFetch');
      final lastFetch = lastFetchStr != null ? DateTime.parse(lastFetchStr) : null;
      
      if (lastFetch != null && 
          DateTime.now().difference(lastFetch) < _cacheTimeout &&
          DataService.productsBox.isNotEmpty) {
        return;
      }

      final result = await DataService.shopifyService.getProducts();
      if (result != null && result.containsKey('products')) {
        final products = result['products'] as List<Product>;
      
        // Clear and update products box
        await DataService.productsBox.clear();
        await DataService.productsBox.putAll(
          Map.fromEntries(products.map((p) => MapEntry(p.id, p)))
        );
      
        // Update last fetch time
        await DataService.cacheBox.put(
          'lastProductFetch', 
          DateTime.now().toIso8601String()
        );
      }
    } catch (e, stackTrace) {
      print('Error loading products: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  static Future<List<Product>> getAllProducts() async {
    if (!DataService.isInitialized) {
      return [];
    }

    try {
      await loadProducts();
      return DataService.productsBox.values.toList();
    } catch (e) {
      print('Error getting all products: $e');
      return [];
    }
  }

  static Future<Product?> getProductById(String id) async {
    if (!DataService.isInitialized) {
      return null;
    }

    try {
      await loadProducts();
      return DataService.productsBox.get(id);
    } catch (e) {
      print('Error getting product by ID: $e');
      return null;
    }
  }

  static Future<List<Product>> getProductsByCategory(String category) async {
    if (!DataService.isInitialized) {
      return [];
    }

    try {
      await loadProducts();
      return DataService.productsBox.values
          .where((p) => p.category == category)
          .toList();
    } catch (e) {
      print('Error getting products by category: $e');
      return [];
    }
  }

  static Future<List<Product>> getOnSaleProducts() async {
    if (!DataService.isInitialized) {
      return [];
    }

    try {
      await loadProducts();
      return DataService.productsBox.values
          .where((p) => p.isOnSale)
          .toList();
    } catch (e) {
      print('Error getting sale products: $e');
      return [];
    }
  }

  static Future<List<Product>> getFeaturedProducts() async {
    if (!DataService.isInitialized) {
      return [];
    }

    try {
      await loadProducts();
      return DataService.productsBox.values
          .where((p) => p.tags.contains('featured'))
          .take(4)
          .toList();
    } catch (e) {
      print('Error getting featured products: $e');
      return [];
    }
  }

  static Future<List<Product>> getNewArrivals() async {
    if (!DataService.isInitialized) {
      return [];
    }

    try {
      await loadProducts();
      final products = DataService.productsBox.values.toList()
        ..sort((a, b) => (b.publishedAt ?? DateTime.now())
            .compareTo(a.publishedAt ?? DateTime.now()));
      return products.take(4).toList();
    } catch (e) {
      print('Error getting new arrivals: $e');
      return [];
    }
  }

  static Future<List<Product>> getBestSellers() async {
    if (!DataService.isInitialized) {
      return [];
    }

    try {
      await loadProducts();
      return DataService.productsBox.values
          .take(4)
          .toList();
    } catch (e) {
      print('Error getting best sellers: $e');
      return [];
    }
  }

  static Future<void> clearCache() async {
    if (!DataService.isInitialized) {
      return;
    }

    try {
      await DataService.productsBox.clear();
      await DataService.cacheBox.delete('lastProductFetch');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}