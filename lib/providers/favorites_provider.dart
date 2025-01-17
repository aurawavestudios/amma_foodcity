import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'package:hive/hive.dart';

class FavoritesProvider with ChangeNotifier {
  Set<String> _favoriteIds = {};
  final Box _favoritesBox = Hive.box('favoritesBox');

  FavoritesProvider() {
    _loadFavoritesFromStorage();
  }

  // Load favorites from Hive storage
  void _loadFavoritesFromStorage() {
    final favoritesList = _favoritesBox.get('favorites', defaultValue: <String>[]);
    _favoriteIds = Set<String>.from(favoritesList);
    notifyListeners();
  }

  // Save favorites to Hive storage
  Future<void> _saveFavoritesToStorage() async {
    await _favoritesBox.put('favorites', _favoriteIds.toList());
  }

  Set<String> get favoriteIds => {..._favoriteIds};

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  Future<void> toggleFavorite(String productId) async {
    try {
      if (_favoriteIds.contains(productId)) {
        _favoriteIds.remove(productId);
      } else {
        _favoriteIds.add(productId);
      }
      
      await _saveFavoritesToStorage();
      notifyListeners();
    } catch (e) {
      print('Error toggling favorite: $e');
      throw e;
    }
  }

  Future<void> clearFavorites() async {
    try {
      _favoriteIds.clear();
      await _saveFavoritesToStorage();
      notifyListeners();
    } catch (e) {
      print('Error clearing favorites: $e');
      throw e;
    }
  }

  int get favoritesCount => _favoriteIds.length;
}