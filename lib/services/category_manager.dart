// lib/services/category_manager.dart
import 'package:flutter/material.dart';
import 'shopify_category_service.dart';
import '../models/product_category.dart';

class CategoryManager {
  final ShopifyCategoryService _categoryService;
  List<Map<String, dynamic>>? _cachedCategories;
  DateTime? _lastFetch;
  static const Duration _cacheTimeout = Duration(minutes: 15);

  CategoryManager(this._categoryService);

  Future<List<Map<String, dynamic>>> getCategories({bool forceRefresh = false}) async {
    if (!forceRefresh && 
        _cachedCategories != null && 
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < _cacheTimeout) {
      return _cachedCategories!;
    }

    try {
      _cachedCategories = await _categoryService.getAllCategories();
      _lastFetch = DateTime.now();
      return _cachedCategories!;
    } catch (e) {
      if (_cachedCategories != null) {
        return _cachedCategories!;
      }
      rethrow;
    }
  }

  Future<List<ProductCategory>> getMainCategories() async {
    try {
      final categories = await getCategories();
      final List<ProductCategory> mainCategories = [];

      for (var group in categories) {
        switch (group['type']) {
          case 'main_categories':
            final collections = group['collections'] as List;
            mainCategories.addAll(collections.map((collection) => ProductCategory(
              id: collection['id'],
              name: collection['title'],
              icon: _getCategoryIcon(collection['title']),
              color: _getCategoryColor(collection['title']),
              imageUrl: collection['imageUrl'],
              description: collection['description'],
              handle: collection['handle'] ?? '',
              subCategories: List<String>.from(collection['subcategories'] ?? []),
              type: 'collection',
              productCount: collection['productCount'] ?? 0,
              lastUpdated: collection['lastUpdated'],
            )));
            break;

          case 'featured':
            // Add featured collections if needed
            break;

          case 'product_types':
            if (group['items'] != null) {
              final types = group['items'] as List;
              mainCategories.addAll(types.map((type) => ProductCategory(
                id: 'type_$type',
                name: type,
                icon: _getCategoryIcon(type),
                color: _getCategoryColor(type),
                handle: type.toLowerCase(),
                type: 'product_type',
              )));
            }
            break;
        }
      }

      return mainCategories;
    } catch (e, stackTrace) {
      print('Error in getMainCategories: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<String>> getSubcategories(String categoryId) async {
    try {
      final categories = await getCategories();
      
      // Look in main categories first
      final mainCategoriesGroup = categories
          .firstWhere((cat) => cat['type'] == 'main_categories', 
                      orElse: () => {'collections': []});
      
      final collections = mainCategoriesGroup['collections'] as List;
      final category = collections
          .firstWhere((cat) => cat['id'] == categoryId, 
                      orElse: () => {'subcategories': []});

      return List<String>.from(category['subcategories'] ?? []);
    } catch (e) {
      print('Error getting subcategories: $e');
      return [];
    }
  }

  Future<Map<String, List<String>>> getAllFilters() async {
    try {
      final categories = await getCategories();
      
      return {
        'productTypes': _getItemsOfType(categories, 'product_types'),
        'brands': _getItemsOfType(categories, 'brands'),
        'tags': _getItemsOfType(categories, 'tags'),
      };
    } catch (e) {
      print('Error getting filters: $e');
      return {
        'productTypes': [],
        'brands': [],
        'tags': [],
      };
    }
  }

  List<String> _getItemsOfType(List<Map<String, dynamic>> categories, String type) {
    try {
      final category = categories.firstWhere(
        (cat) => cat['type'] == type,
        orElse: () => {'items': <String>[]},
      );
      return List<String>.from(category['items'] ?? []);
    } catch (e) {
      print('Error getting items of type $type: $e');
      return [];
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('grocer')) return Icons.shopping_basket;
    if (name.contains('vegetable') || name.contains('produce')) return Icons.eco;
    if (name.contains('fruit')) return Icons.apple;
    if (name.contains('meat')) return Icons.restaurant_menu;
    if (name.contains('seafood')) return Icons.set_meal;
    if (name.contains('dairy')) return Icons.egg_alt;
    if (name.contains('spice')) return Icons.spa;
    if (name.contains('beverage')) return Icons.local_drink;
    if (name.contains('snack')) return Icons.cookie;
    if (name.contains('household')) return Icons.home;
    if (name.contains('health')) return Icons.favorite;
    if (name.contains('international')) return Icons.public;
    return Icons.category;
  }

  Color _getCategoryColor(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('grocer')) return Colors.amber;
    if (name.contains('vegetable') || name.contains('produce')) return Colors.green;
    if (name.contains('fruit')) return Colors.red;
    if (name.contains('meat')) return Colors.redAccent;
    if (name.contains('seafood')) return Colors.blueAccent;
    if (name.contains('dairy')) return Colors.blue;
    if (name.contains('spice')) return Colors.orange;
    if (name.contains('beverage')) return Colors.purple;
    if (name.contains('snack')) return Colors.deepOrange;
    if (name.contains('household')) return Colors.teal;
    if (name.contains('health')) return Colors.pink;
    if (name.contains('international')) return Colors.indigo;
    return Colors.grey;
  }
}