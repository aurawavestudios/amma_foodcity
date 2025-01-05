// lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/shopify_service.dart';

class CartItem
{
  final String id;
  final String name;
  final int quantity;
  final String price;
  final String imagePath;

  CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imagePath,
  });
}

class CartProvider with ChangeNotifier
{
  final ShopifyService _shopifyService = ShopifyService();
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items
{
    return {..._items};
  }

  int get itemCount
{
    return _items.length;
  }

  double get totalAmount
{
    var total = 0.0;
    _items.forEach((key, cartItem)
{
      total += double.parse(cartItem.price) * cartItem.quantity;
    });
    return total;
  }

Future<void> addItem(Product product) async {
    try {
      // Add to Shopify cart
      await _shopifyService.addToCart(product.id, 1);

      // Update local state
      if (_items.containsKey(product.id)) {
        _items.update(
          product.id,
          (existingCartItem) => CartItem(
            id: existingCartItem.id,
            name: existingCartItem.name,
            quantity: existingCartItem.quantity + 1,
            price: product.isOnSale ? (product.salePrice ?? product.price) : product.price,
            imagePath: product.imagePath,
          ),
        );
      } else {
        _items.putIfAbsent(
          product.id,
          () => CartItem(
            id: product.id,
            name: product.name,
            quantity: 1,
            price: product.isOnSale ? (product.salePrice ?? product.price) : product.price,
            imagePath: product.imagePath,
          ),
        );
      }
      notifyListeners();
    } catch (e) {
      print('Error adding item to cart: $e');
      throw e;
    }
  }

  Future<void> removeItem(String productId) async {
    try {
      // Remove from Shopify cart
      // Implement Shopify cart removal logic here
      
      // Update local state
      _items.remove(productId);
      notifyListeners();
    } catch (e) {
      print('Error removing item from cart: $e');
      throw e;
    }
  }

  Future<void> clear() async {
    try {
      // Clear Shopify cart
      // Implement Shopify cart clearing logic here
      
      // Update local state
      _items = {};
      notifyListeners();
    } catch (e) {
      print('Error clearing cart: $e');
      throw e;
    }
  }
}
