import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/product.dart';
import '../services/shopify_service.dart';

class CartItem {
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

  // Convert CartItem to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imagePath': imagePath,
    };
  }

  // Create CartItem from Map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      price: map['price'],
      imagePath: map['imagePath'],
    );
  }
}

class CartProvider with ChangeNotifier {
  final ShopifyService _shopifyService = ShopifyService();
  Map<String, CartItem> _items = {};
  final Box _cartBox = Hive.box('cartBox');

  CartProvider() {
    _loadCartFromStorage();
  }

  // Load cart items from Hive storage
  void _loadCartFromStorage() {
    final cartData = _cartBox.get('cart', defaultValue: {});
    _items = Map.from(cartData).map((key, value) => MapEntry(
          key.toString(),
          CartItem.fromMap(Map<String, dynamic>.from(value)),
        ));
    notifyListeners();
  }

  // Save cart items to Hive storage
  Future<void> _saveCartToStorage() async {
    final cartData = _items.map((key, item) => MapEntry(key, item.toMap()));
    await _cartBox.put('cart', cartData);
  }

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
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
            price: product.isOnSale 
              ? (product.salePrice ?? product.price) 
              : product.price,
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
            price: product.isOnSale 
              ? (product.salePrice ?? product.price) 
              : product.price,
            imagePath: product.imagePath,
          ),
        );
      }

      await _saveCartToStorage();
      notifyListeners();
    } catch (e) {
      print('Error adding item to cart: $e');
      throw e;
    }
  }

  Future<void> removeItem(String productId) async {
    try {
      _items.remove(productId);
      await _saveCartToStorage();
      notifyListeners();
    } catch (e) {
      print('Error removing item from cart: $e');
      throw e;
    }
  }

  Future<void> removeSingleItem(String productId) async {
    try {
      if (!_items.containsKey(productId)) return;

      if (_items[productId]!.quantity > 1) {
        _items.update(
          productId,
          (existingCartItem) => CartItem(
            id: existingCartItem.id,
            name: existingCartItem.name,
            quantity: existingCartItem.quantity - 1,
            price: existingCartItem.price,
            imagePath: existingCartItem.imagePath,
          ),
        );
      } else {
        _items.remove(productId);
      }

      await _saveCartToStorage();
      notifyListeners();
    } catch (e) {
      print('Error updating cart item: $e');
      throw e;
    }
  }

  Future<void> clear() async {
    try {
      _items = {};
      await _saveCartToStorage();
      notifyListeners();
    } catch (e) {
      print('Error clearing cart: $e');
      throw e;
    }
  }
}