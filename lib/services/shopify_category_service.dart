// lib/services/shopify_category_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/product_category.dart';
import '../config/shopify_config.dart';

class ShopifyCategoryService {
  final GraphQLClient _client;

  ShopifyCategoryService(this._client);

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    const String getCategoriesQuery = r'''
      query GetAllCategories {
        collections(first: 250) {
          edges {
            node {
              id
              title
              description
              handle
              image {
                url
                altText
              }
              products(first: 1) {
                pageInfo {
                  hasNextPage
                  hasPreviousPage
                }
                edges {
                  node {
                    productType
                  }
                }
              }
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
        products(first: 250) {
          edges {
            node {
              productType
              vendor
              tags
            }
          }
          pageInfo {
            hasNextPage
            endCursor
          }
        }
      }
    ''';

    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(getCategoriesQuery),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      if (result.data == null) {
        throw Exception('No data received from Shopify');
      }

      final collectionsData = result.data!['collections']['edges'] as List<dynamic>;
      final productsData = result.data!['products']['edges'] as List<dynamic>;

      // Get all product types
      final Set<String> productTypes = productsData
          .map((edge) => edge['node']['productType'] as String)
          .where((type) => type.isNotEmpty)
          .toSet();

      // Get all vendors
      final Set<String> vendors = productsData
          .map((edge) => edge['node']['vendor'] as String)
          .where((vendor) => vendor.isNotEmpty)
          .toSet();

      // Get all tags
      final Set<String> tags = productsData
          .expand((edge) => (edge['node']['tags'] as List<dynamic>).cast<String>())
          .where((tag) => tag.isNotEmpty)
          .toSet();

      // Parse collections
      final List<Map<String, dynamic>> collections = collectionsData
          .map((edge) => _parseCollectionNode(edge['node'] as Map<String, dynamic>))
          .toList();

      // Organize categories
      return _organizeCategories(
        collections: collections,
        productTypes: productTypes.toList(),
        vendors: vendors.toList(),
        tags: tags.toList(),
      );
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }

  Future<List<ProductCategory>> getCategories() async {
    try {
      final rawCategories = await getAllCategories();
      final List<ProductCategory> categories = [];

      for (var categoryGroup in rawCategories) {
        switch (categoryGroup['type']) {
          case 'main_categories':
          case 'featured':
          case 'seasonal':
            final collections = categoryGroup['collections'] as List<dynamic>;
            categories.addAll(collections.map((collection) => ProductCategory(
              id: collection['id'],
              name: collection['title'],
              description: collection['description'] ?? '',
              imageUrl: collection['imageUrl'],
              handle: collection['handle'],
              icon: _getCategoryIcon(collection['title']),
              color: _getCategoryColor(collection['title']),
              type: categoryGroup['type'],
              lastUpdated: DateTime.now(),
            )));
            break;

          case 'product_types':
            final items = categoryGroup['items'] as List<String>;
            categories.addAll(items.map((type) => ProductCategory(
              id: 'type_$type',
              name: type,
              handle: type.toLowerCase(),
              icon: _getCategoryIcon(type),
              color: _getCategoryColor(type),
              type: 'product_type',
              lastUpdated: DateTime.now(),
              description: '',
              imageUrl: null,
            )));
            break;

          case 'brands':
            final items = categoryGroup['items'] as List<String>;
            categories.addAll(items.map((brand) => ProductCategory(
              id: 'brand_$brand',
              name: brand,
              handle: brand.toLowerCase(),
              icon: Icons.business,
              color: Colors.blue,
              type: 'brand',
              lastUpdated: DateTime.now(),
              description: '',
              imageUrl: null,
            )));
            break;
        }
      }

      return categories;
    } catch (e, stackTrace) {
      print('Error converting categories: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  IconData _getCategoryIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('grocer')) return Icons.shopping_basket;
    if (lowerName.contains('produce')) return Icons.eco;
    if (lowerName.contains('meat')) return Icons.set_meal;
    if (lowerName.contains('dairy')) return Icons.egg_alt;
    if (lowerName.contains('beverage')) return Icons.local_drink;
    if (lowerName.contains('snack')) return Icons.cookie;
    if (lowerName.contains('household')) return Icons.home;
    if (lowerName.contains('international')) return Icons.public;
    return Icons.category;
  }

  Color _getCategoryColor(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('grocer')) return Colors.amber;
    if (lowerName.contains('produce')) return Colors.green;
    if (lowerName.contains('meat')) return Colors.red;
    if (lowerName.contains('dairy')) return Colors.blue;
    if (lowerName.contains('beverage')) return Colors.purple;
    if (lowerName.contains('snack')) return Colors.orange;
    if (lowerName.contains('household')) return Colors.teal;
    if (lowerName.contains('international')) return Colors.indigo;
    return Colors.grey;
  }

  Map<String, dynamic> _parseCollectionNode(Map<String, dynamic> node) {
    return {
      'id': node['id'],
      'title': node['title'],
      'description': node['description'],
      'handle': node['handle'],
      'imageUrl': node['image']?['url'],
      'productCount': node['products']['edges'].length,
      'categoryType': 'main', // Default to main if no metafields
    };
  }

  List<Map<String, dynamic>> _organizeCategories({
    required List<Map<String, dynamic>> collections,
    required List<String> productTypes,
    required List<String> vendors,
    required List<String> tags,
  }) {
    // Group collections by category type
    final mainCollections = collections.where((c) => c['categoryType'] == 'main').toList();
    final featuredCollections = collections.where((c) => c['categoryType'] == 'featured').toList();
    final seasonalCollections = collections.where((c) => c['categoryType'] == 'seasonal').toList();

    final categories = <Map<String, dynamic>>[
      {
        'type': 'main_categories',
        'title': 'Main Categories',
        'collections': mainCollections,
      },
      {
        'type': 'product_types',
        'title': 'Product Types',
        'items': productTypes,
      },
      {
        'type': 'brands',
        'title': 'Brands',
        'items': vendors,
      },
    ];

    if (featuredCollections.isNotEmpty) {
      categories.add({
        'type': 'featured',
        'title': 'Featured Collections',
        'collections': featuredCollections,
      });
    }

    if (seasonalCollections.isNotEmpty) {
      categories.add({
        'type': 'seasonal',
        'title': 'Seasonal Collections',
        'collections': seasonalCollections,
      });
    }

    return categories;
  }
}