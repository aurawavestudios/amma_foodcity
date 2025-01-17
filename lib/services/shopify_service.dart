// lib/services/shopify_service.dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_category.dart';
import '../models/product.dart';
import '../config/shopify_config.dart';

class ShopifyService {
  late GraphQLClient _client;
  SharedPreferences? _prefs;

  // Singleton pattern
  static final ShopifyService _instance = ShopifyService._internal();
  factory ShopifyService() => _instance;

  ShopifyService._internal() {
    _initializeClient();
  }

  void _initializeClient() {
    final HttpLink httpLink = HttpLink(
      ShopifyConfig.storefrontUrl,
      defaultHeaders: {
        'X-Shopify-Storefront-Access-Token': ShopifyConfig.storefrontAccessToken,
      },
    );

    _client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(
        store: HiveStore(),
      ),
    );
  }

   // Get GraphQL client
  GraphQLClient getClient() {
    return _client;
  }

  // Add to Cart Method
  Future<void> addToCart(String variantId, int quantity) async {
    const String mutation = r'''
      mutation cartCreate($input: CartInput!) {
        cartCreate(input: $input) {
          cart {
            id
            lines(first: 10) {
              edges {
                node {
                  id
                  quantity
                  merchandise {
                    ... on ProductVariant {
                      id
                    }
                  }
                }
              }
            }
          }
          userErrors {
            field
            message
          }
        }
      }
    ''';

    try {
      final MutationOptions options = MutationOptions(
        document: gql(mutation),
        variables: {
          'input': {
            'lines': [
              {
                'quantity': quantity,
                'merchandiseId': variantId,
              }
            ],
          }
        },
      );

      final QueryResult result = await _client.mutate(options);

      if (result.hasException) {
        throw result.exception!;
      }

      if (result.data?['cartCreate']['userErrors']?.isNotEmpty) {
        throw Exception(result.data!['cartCreate']['userErrors'][0]['message']);
      }
    } catch (e) {
      print('Error adding to cart: $e');
      throw e;
    }
  }

  Future<List<ProductCategory>> getCollections() async {
  try {
    const String query = r'''
      query GetCollections {
        collections(first: 250) {
          edges {
            node {
              id
              title
              description
              handle
              updatedAt
              image {
                url
                altText
              }
              metafields(first: 10) {
                edges {
                  node {
                    key
                    value
                  }
                }
              }
              products(first: 1) {
                totalCount
              }
            }
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
        }
      }
    ''';

    final QueryResult result = await _client.query(
      QueryOptions(
        document: gql(query),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      print('GraphQL Error: ${result.exception}');
      throw result.exception!;
    }

    if (result.data == null) {
      throw Exception('No data received from Shopify');
    }

    final List<ProductCategory> categories = [];

    // Process collections safely
    if (result.data!.containsKey('collections') && 
        result.data!['collections']?['edges'] != null) {
      final collections = result.data!['collections']['edges'] as List<dynamic>;
      for (var edge in collections) {
        if (edge['node'] != null) {
          final node = edge['node'];
          final title = node['title']?.toString() ?? '';
          categories.add(
            ProductCategory.fromShopify(
              node,
              icon: _getCollectionIcon(title),
              color: _getCollectionColor(title),
            ),
          );
        }
      }
    }

    // Process product types safely
    if (result.data!.containsKey('products') && 
        result.data!['products']?['edges'] != null) {
      final products = result.data!['products']['edges'] as List<dynamic>;
      final Set<String> productTypes = {};

      for (var edge in products) {
        if (edge['node'] != null) {
          final type = edge['node']['productType']?.toString();
          if (type != null && type.isNotEmpty) {
            productTypes.add(type);
          }
        }
      }

      // Add unique product types as categories
      for (var type in productTypes) {
        // Create a node structure similar to collections for factory constructor
        final typeNode = {
          'id': 'type_$type',
          'title': type,
          'description': 'Products of type $type',
          'handle': type.toLowerCase(),
          'products': {'totalCount': 0},
          'metafields': {'edges': []},
        };

        categories.add(
          ProductCategory.fromShopify(
            typeNode,
            icon: _getCollectionIcon(type),
            color: _getCollectionColor(type),
          ).copyWith(type: 'product_type'), // Override type for product types
        );
      }
    }

    return categories;
  } catch (e, stackTrace) {
    print('Error fetching collections: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

  // Get Subcategories (Product Types) for a Collection
  Future<List<String>> getSubcategoriesForCollection(String collectionId) async {
    const String query = r'''
      query GetCollectionProductTypes($id: ID!) {
        collection(id: $id) {
          products(first: 100) {
            edges {
              node {
                productType
              }
            }
          }
        }
      }
    ''';

    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(query),
          variables: {'id': collectionId},
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      final List<dynamic> edges = result.data!['collection']['products']['edges'];
      final Set<String> productTypes = edges
          .map((edge) => edge['node']['productType'] as String)
          .where((type) => type.isNotEmpty)
          .toSet();

      return productTypes.toList()..sort();
    } catch (e) {
      print('Error fetching subcategories: $e');
      throw e;
    }
  }
   
  // Update the getProducts() method to use the new products query:
Future<Map<String, dynamic>> getProducts({
  String? collectionId,
  String? productType,
  String? searchQuery,
  int first = 20,
  String? sortKey,
  bool reverse = false,
  double? maxPrice,
  double? minPrice,
  bool? isOnSale,
  List<String>? tags,
}) async {
  String queryBuilder() {
    List<String> filters = [];
    
    if (collectionId != null) filters.add('collection_id:$collectionId');
    if (productType != null) filters.add('product_type:$productType');
    if (searchQuery != null) filters.add('title:*$searchQuery*');
    if (maxPrice != null) filters.add('price:<=$maxPrice');
    if (minPrice != null) filters.add('price:>=$minPrice');
    if (isOnSale == true) filters.add('variants.compare_at_price:>0');
    if (tags != null && tags.isNotEmpty) {
      filters.addAll(tags.map((tag) => 'tag:$tag'));
    }

    return filters.join(' AND ');
  }
   const String _productsQuery = r'''
    query GetFilteredProducts(
      $first: Int!
      $query: String
      $sortKey: ProductSortKeys
      $reverse: Boolean
    ) {
      products(
        first: $first
        query: $query
        sortKey: $sortKey
        reverse: $reverse
      ) {
        edges {
          node {
            id
            title
            description
            handle
            productType
            tags
            vendor
            priceRange {
              minVariantPrice {
                amount
              }
              maxVariantPrice {
                amount
              }
            }
            images(first: 5) {
              edges {
                node {
                  url
                  altText
                }
              }
            }
            variants(first: 1) {
              edges {
                node {
                  id
                  price {
                    amount
                  }
                  compareAtPrice {
                    amount
                  }
                  availableForSale
                  quantityAvailable
                }
              }
            }
            metafields(
              identifiers: [
                {namespace: "custom", key: "origin"},
                {namespace: "custom", key: "storage"}
              ]
            ) {
              key
              value
              namespace
            }
          }
          cursor
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
        document: gql(_productsQuery), // Use the updated query
        variables: {
          'first': first,
          'query': queryBuilder(),
          'sortKey': sortKey,
          'reverse': reverse,
        },
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final products = _parseProducts(result.data!['products']['edges']);
    final pageInfo = result.data!['products']['pageInfo'];

    return {
      'products': products,
      'hasNextPage': pageInfo['hasNextPage'],
      'endCursor': pageInfo['endCursor'],
    };
  } catch (e) {
    print('Error fetching products: $e');
    throw e;
  }
}

  // Cache Management
  Future<void> _cacheData(String key, Map<String, dynamic> data) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(key, data.toString());
    await _prefs!.setInt('${key}_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  Future<Map<String, dynamic>?> _getCachedData(String key) async {
    _prefs ??= await SharedPreferences.getInstance();
    
    final timestamp = _prefs!.getInt('${key}_timestamp');
    if (timestamp == null) return null;

    final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
    if (cacheAge > ShopifyConfig.cacheTimeInMinutes * 60 * 1000) return null;

    final cachedString = _prefs!.getString(key);
    if (cachedString == null) return null;

    // Convert string back to Map
    try {
      // Implement proper string to map conversion
      return {};
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCache() async {
    _prefs ??= await SharedPreferences.getInstance();
    final keys = _prefs!.getKeys().where((key) => 
      key.endsWith('_timestamp') || key == 'collections' || key == 'products'
    );
    for (var key in keys) {
      await _prefs!.remove(key);
    }
  }

  // Helper Methods
    Map<String, String> _parseMetafields(List<dynamic> metafields) {
    final Map<String, String> result = {};
    for (var metafield in metafields) {
      if (metafield != null) {
        final key = metafield['key'].toString().split('.').last;
        result[key] = metafield['value'];
      }
    }
    return result;
  }

    List<Product> _parseProducts(List<dynamic> edges) {
    return edges.map((edge) {
      final node = edge['node'];
      final variant = node['variants']['edges'][0]['node'];
      final price = variant['price']['amount'];
      final compareAtPrice = variant['compareAtPrice']?['amount'];
      final images = node['images']['edges']
          .map((imgEdge) => imgEdge['node']['url'].toString())
          .toList();
      
      // Parse metafields directly
      final metafields = _parseMetafields(node['metafields'] ?? []);

      return Product(
        id: node['id'],
        name: node['title'],
        price: price.toString(),
        salePrice: compareAtPrice?.toString(),
        weight: 0,
        isOnSale: compareAtPrice != null,
        imagePath: images.isNotEmpty ? images.first : '',
        imageUrls: List<String>.from(images),
        description: node['description'] ?? '',
        category: node['productType'] ?? 'Default',
        categoryId: '1',
        subCategory: node['productType'] ?? 'Default',
        origin: metafields['origin'] ?? '',
        storage: metafields['storage'] ?? '',
        vendor: node['vendor'] ?? '',
        tags: List<String>.from(node['tags'] ?? []),
        handle: node['handle'] ?? '',
        quantityAvailable: variant['quantityAvailable'],
        isAvailable: variant['availableForSale'] ?? true,
        variantId: variant['id'],
        metafields: metafields,
      );
    }).toList();
  }

  IconData _getCollectionIcon(String name) {
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

Color _getCollectionColor(String name) {
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
  
}