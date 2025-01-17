// lib/models/category.dart
import 'package:flutter/material.dart';

@immutable
class ProductCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<String>? subCategories;
  final String? imageUrl;
  final String? description;
  final String handle;
  final String type;  // 'collection' or 'product_type'
  final int productCount;
  final Map<String, String>? metafields;
  final DateTime? lastUpdated;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.subCategories,
    this.imageUrl,
    this.description,
    this.handle = '',
    this.type = 'collection',
    this.productCount = 0,
    this.metafields,
    this.lastUpdated,
  });

  factory ProductCategory.fromShopify(Map<String, dynamic> node, {
    required IconData icon,
    required Color color,
  }) {
    return ProductCategory(
      id: node['id'],
      name: node['title'],
      icon: icon,
      color: color,
      description: node['description'],
      imageUrl: node['image']?['url'],
      handle: node['handle'] ?? '',
      type: 'collection',
      productCount: node['products']?['totalCount'] ?? 0,
      metafields: (node['metafields']?['edges'] as List?)
          ?.map((edge) => MapEntry(
                edge['node']['key'] as String,
                edge['node']['value'] as String,
              ))
          .fold<Map<String, String>>(
            {},
            (map, entry) => map..addAll({entry.key: entry.value}),
          ),
      lastUpdated: node['updatedAt'] != null 
          ? DateTime.parse(node['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'imageUrl': imageUrl,
    'handle': handle,
    'type': type,
    'productCount': productCount,
    'metafields': metafields,
    'lastUpdated': lastUpdated?.toIso8601String(),
  };

  ProductCategory copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    List<String>? subCategories,
    String? imageUrl,
    String? description,
    String? handle,
    String? type,
    int? productCount,
    Map<String, String>? metafields,
    DateTime? lastUpdated,
  }) {
    return ProductCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      subCategories: subCategories ?? this.subCategories,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      handle: handle ?? this.handle,
      type: type ?? this.type,
      productCount: productCount ?? this.productCount,
      metafields: metafields ?? this.metafields,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}