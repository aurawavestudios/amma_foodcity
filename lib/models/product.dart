// lib/models/product.dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
part 'product.g.dart';

@HiveType(typeId: 0)
@immutable
class Product {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String price;

  @HiveField(3)
  final String? salePrice;

  @HiveField(4)
  final int weight;

  @HiveField(5)
  final bool isOnSale;

  @HiveField(6)
  final String imagePath;

  @HiveField(7)
  final List<String> imageUrls;

  @HiveField(8)
  final String description;

  @HiveField(9)
  final String category;

  @HiveField(10)
  final String categoryId;

  @HiveField(11)
  final String subCategory;

  @HiveField(12)
  final String origin;

  @HiveField(13)
  final String storage;

  @HiveField(14)
  final String vendor;

  @HiveField(15)
  final List<String> tags;

  @HiveField(16)
  final String handle;

  @HiveField(17)
  final int? quantityAvailable;

  @HiveField(18)
  final bool isAvailable;

  @HiveField(19)
  final String variantId;

  @HiveField(20)
  final Map<String, String>? metafields;

  @HiveField(21)
  final DateTime? publishedAt;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.weight,
    this.salePrice,
    required this.isOnSale,
    required this.imagePath,
    required this.imageUrls,
    required this.description,
    required this.category,
    required this.categoryId,
    required this.subCategory,
    required this.origin,
    required this.storage,
    this.vendor = '',
    this.tags = const [],
    this.handle = '',
    this.quantityAvailable,
    this.isAvailable = true,
    this.variantId = '',
    this.metafields,
    this.publishedAt,
  });

  List<String> get allImages => [imagePath, ...imageUrls];

  factory Product.fromShopify(Map<String, dynamic> node) {
    final variant = node['variants']['edges'][0]['node'];
    final price = variant['price']['amount'];
    final compareAtPrice = variant['compareAtPrice']?['amount'];
    final images = (node['images']['edges'] as List?)
        ?.map((imgEdge) => imgEdge['node']['url'].toString())
        .toList() ?? [];

    return Product(
      id: node['id']?.toString() ?? '',
      name: node['title']?.toString() ?? '',
      price: price?.toString() ?? '0',
      salePrice: compareAtPrice?.toString(),
      weight: 0,
      isOnSale: compareAtPrice != null,
      imagePath: images.isNotEmpty ? images.first : '',
      imageUrls: images,
      description: node['description']?.toString() ?? '',
      category: node['productType']?.toString() ?? 'Default',
      categoryId: node['collections']?['edges']?[0]?['node']?['id']?.toString() ?? '1',
      subCategory: node['productType']?.toString() ?? 'Default',
      origin: node['vendor']?.toString() ?? '',
      storage: '',
      vendor: node['vendor']?.toString() ?? '',
      tags: List<String>.from(node['tags'] ?? []),
      handle: node['handle']?.toString() ?? '',
      quantityAvailable: variant['quantityAvailable'] as int?,
      isAvailable: variant['availableForSale'] as bool? ?? true,
      variantId: variant['id']?.toString() ?? '',
      publishedAt: node['publishedAt'] != null 
          ? DateTime.tryParse(node['publishedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': name,
    'price': price,
    'salePrice': salePrice,
    'weight': weight,
    'isOnSale': isOnSale,
    'imagePath': imagePath,
    'imageUrls': imageUrls,
    'description': description,
    'category': category,
    'categoryId': categoryId,
    'subCategory': subCategory,
    'origin': origin,
    'storage': storage,
    'vendor': vendor,
    'tags': tags,
    'handle': handle,
    'quantityAvailable': quantityAvailable,
    'isAvailable': isAvailable,
    'variantId': variantId,
    'metafields': metafields,
    'publishedAt': publishedAt?.toIso8601String(),
  };

  Product copyWith({
    String? id,
    String? name,
    String? price,
    String? salePrice,
    int? weight,
    bool? isOnSale,
    String? imagePath,
    List<String>? imageUrls,
    String? description,
    String? category,
    String? categoryId,
    String? subCategory,
    String? origin,
    String? storage,
    String? vendor,
    List<String>? tags,
    String? handle,
    int? quantityAvailable,
    bool? isAvailable,
    String? variantId,
    Map<String, String>? metafields,
    DateTime? publishedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      weight: weight ?? this.weight,
      isOnSale: isOnSale ?? this.isOnSale,
      imagePath: imagePath ?? this.imagePath,
      imageUrls: imageUrls ?? this.imageUrls,
      description: description ?? this.description,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      subCategory: subCategory ?? this.subCategory,
      origin: origin ?? this.origin,
      storage: storage ?? this.storage,
      vendor: vendor ?? this.vendor,
      tags: tags ?? this.tags,
      handle: handle ?? this.handle,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      isAvailable: isAvailable ?? this.isAvailable,
      variantId: variantId ?? this.variantId,
      metafields: metafields ?? this.metafields,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}