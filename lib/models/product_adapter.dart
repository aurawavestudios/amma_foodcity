// lib/models/product_adapter.dart
import 'package:hive/hive.dart';
import 'product.dart';

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    try {
      final Map<dynamic, dynamic> rawData = reader.readMap();
      // Convert all keys to strings to ensure type safety
      final Map<String, dynamic> data = Map<String, dynamic>.from(rawData);
      
      return Product(
        id: data['id']?.toString() ?? '',
        name: data['name']?.toString() ?? '',
        price: data['price']?.toString() ?? '0',
        weight: data['weight'] as int? ?? 0,
        salePrice: data['salePrice']?.toString(),
        isOnSale: data['isOnSale'] as bool? ?? false,
        imagePath: data['imagePath']?.toString() ?? '',
        imageUrls: (data['imageUrls'] as List?)
            ?.map((e) => e.toString())
            .toList() ?? [],
        description: data['description']?.toString() ?? '',
        category: data['category']?.toString() ?? '',
        categoryId: data['categoryId']?.toString() ?? '',
        subCategory: data['subCategory']?.toString() ?? '',
        origin: data['origin']?.toString() ?? '',
        storage: data['storage']?.toString() ?? '',
        vendor: data['vendor']?.toString() ?? '',
        tags: (data['tags'] as List?)
            ?.map((e) => e.toString())
            .toList() ?? [],
        handle: data['handle']?.toString() ?? '',
        quantityAvailable: data['quantityAvailable'] as int? ?? 0,
        isAvailable: data['isAvailable'] as bool? ?? true,
        variantId: data['variantId']?.toString() ?? '',
        metafields: data['metafields'] != null
            ? Map<String, String>.from(
                (data['metafields'] as Map).map(
                  (key, value) => MapEntry(
                    key.toString(),
                    value?.toString() ?? '',
                  ),
                ),
              )
            : {},
        publishedAt: data['publishedAt'] != null
            ? DateTime.tryParse(data['publishedAt'].toString())
            : null,
      );
    } catch (e) {
      print('Error reading product from Hive: $e');
      // Return a default product if reading fails
      return Product(
        id: '',
        name: '',
        price: '0',
        weight: 0,
        isOnSale: false,
        imagePath: '',
        imageUrls: [],
        description: '',
        category: '',
        categoryId: '',
        subCategory: '',
        origin: '',
        storage: '',
      );
    }
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    try {
      writer.writeMap(obj.toJson());
    } catch (e) {
      print('Error writing product to Hive: $e');
      // Write empty map as fallback
      writer.writeMap({});
    }
  }
}