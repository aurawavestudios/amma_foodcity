// lib/services/data_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/product.dart';
import 'shopify_service.dart';

class DataService {
  static const String productsBoxName = 'productsBox';
  static const String cartBoxName = 'cartBox';
  static const String favoritesBoxName = 'favoritesBox';
  static const String cacheBoxName = 'cacheBox';
  static const String graphqlBoxName = 'graphqlBox';

  static late Box<Product> productsBox;
  static late Box<Map<dynamic, dynamic>> cartBox;
  static late Box<List<dynamic>> favoritesBox;
  static late Box<dynamic> cacheBox;
  static late Box<dynamic> graphqlBox;
  static late ShopifyService shopifyService;

  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Initialize Hive
      await Hive.initFlutter();
      
      // Register the generated adapter
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ProductAdapter());  // This uses the generated adapter
      }

      // Initialize GraphQL store
      await initHiveForFlutter();

      // Open boxes with error handling
      try {
        graphqlBox = await Hive.openBox(graphqlBoxName);
      } catch (e) {
        await Hive.deleteBoxFromDisk(graphqlBoxName);
        graphqlBox = await Hive.openBox(graphqlBoxName);
      }

      try {
        productsBox = await Hive.openBox<Product>(productsBoxName);
      } catch (e) {
        await Hive.deleteBoxFromDisk(productsBoxName);
        productsBox = await Hive.openBox<Product>(productsBoxName);
      }

      try {
        cartBox = await Hive.openBox<Map>(cartBoxName);
      } catch (e) {
        await Hive.deleteBoxFromDisk(cartBoxName);
        cartBox = await Hive.openBox<Map>(cartBoxName);
      }

      try {
        favoritesBox = await Hive.openBox<List>(favoritesBoxName);
      } catch (e) {
        await Hive.deleteBoxFromDisk(favoritesBoxName);
        favoritesBox = await Hive.openBox<List>(favoritesBoxName);
      }

      try {
        cacheBox = await Hive.openBox(cacheBoxName);
      } catch (e) {
        await Hive.deleteBoxFromDisk(cacheBoxName);
        cacheBox = await Hive.openBox(cacheBoxName);
      }

      // Initialize services
      shopifyService = ShopifyService();
      
      _isInitialized = true;
      print('DataService initialized successfully');
    } catch (e, stackTrace) {
      print('Error initializing DataService: $e');
      print('Stack trace: $stackTrace');
      _isInitialized = false;
      rethrow;
    }
  }

  static bool get isInitialized => _isInitialized;

  static Future<void> clearAll() async {
    if (!_isInitialized) return;

    await Future.wait([
      productsBox.clear(),
      cartBox.clear(),
      favoritesBox.clear(),
      cacheBox.clear(),
      graphqlBox.clear(),
    ]);
  }

  static Future<void> closeAll() async {
    if (!_isInitialized) return;

    await Future.wait([
      productsBox.close(),
      cartBox.close(),
      favoritesBox.close(),
      cacheBox.close(),
      graphqlBox.close(),
    ]);
    _isInitialized = false;
  }
}