// lib/data/product_data.dart
import '../models/product.dart';
import '../services/shopify_service.dart';

class ProductsData {
  static final ShopifyService _shopifyService = ShopifyService();
  static List<Product> _products = [];

  static Future<void> loadProducts() async {
    try {
      _products = await _shopifyService.getProducts();
    } catch (e) {
      print('Error loading products: $e');
      _products = [];
    }
  }

  static List<Product> getAllProducts() {
    return _products;
  }

  static Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Product> getProductsByCategory(String category) {
    return _products
        .where((product) => product.category == category)
        .toList();
  }

  static List<Product> getOnSaleProducts() {
    return _products.where((product) => product.isOnSale).toList();
  }

  static List<Product> getFeaturedProducts() {
    // You might want to get this from a specific Shopify collection
    return _products.take(4).toList();
  }

  static List<Product> getNewArrivals() {
    // Sort by creation date and take latest
    return _products.reversed.take(4).toList();
  }

  static List<Product> getBestSellers() {
    // This could come from a "Best Sellers" collection in Shopify
    return _products.where((product) => product.isOnSale).toList();
  }
}