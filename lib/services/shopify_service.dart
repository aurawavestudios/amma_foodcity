// lib/services/shopify_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/product.dart';

class ShopifyConfig {
  static const String shopDomain = 'khb11m-aw.myshopify.com';
  static const String storefrontAccessToken = '602cf40738a3ccd7928d4794fef0e263';
  static const String apiVersion = '2024-01';

  static String get apiUrl => 
    'https://$shopDomain/api/$apiVersion/graphql.json';
}

class ShopifyService {
  late GraphQLClient _client;

  ShopifyService() {
    final HttpLink httpLink = HttpLink(
      'https://${ShopifyConfig.shopDomain}/api/2024-01/graphql',
      defaultHeaders: {
        'X-Shopify-Storefront-Access-Token': ShopifyConfig.storefrontAccessToken,
      },
    );

    _client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );
  }

  Future<List<Product>> getProducts() async {
    const String query = r'''
      query GetProducts {
        products(first: 20) {
          edges {
            node {
              id
              title
              description
              priceRange {
                minVariantPrice {
                  amount
                  currencyCode
                }
              }
              images(first: 1) {
                edges {
                  node {
                    originalSrc
                  }
                }
              }
            }
          }
        }
      }
    ''';

    final QueryResult result = await _client.query(
      QueryOptions(document: gql(query)),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final List<Product> products = [];
    final List<dynamic> edges = result.data!['products']['edges'];

    for (var edge in edges) {
      final node = edge['node'];
      final priceAmount = node['priceRange']['minVariantPrice']['amount'];
      final imageUrl = node['images']['edges'][0]['node']['originalSrc'];

      products.add(Product(
        id: node['id'],
        name: node['title'],
        price: priceAmount.toString(),
        weight: 0, // You'll need to get this from variants
        isOnSale: false, // Check variants for sales
        imagePath: imageUrl,
        imageUrls: [imageUrl],
        description: node['description'],
        category: 'Default', // You'll need to get this from product type or collections
        categoryId: '1',
        subCategory: 'Default',
        origin: '',
        storage: '',
      ));
    }

    return products;
  }

  // Add to cart mutation
  Future<void> addToCart(String variantId, int quantity) async {
    const String mutation = r'''
      mutation CreateCart($variantId: ID!, $quantity: Int!) {
        cartCreate(input: {
          lines: [{ quantity: $quantity, merchandiseId: $variantId }]
        }) {
          cart {
            id
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'variantId': variantId,
        'quantity': quantity,
      },
    );

    final QueryResult result = await _client.mutate(options);

    if (result.hasException) {
      throw result.exception!;
    }
  }

  // Get collections
  Future<List<Map<String, dynamic>>> getCollections() async {
    const String query = r'''
      query GetCollections {
        collections(first: 10) {
          edges {
            node {
              id
              title
              description
              image {
                originalSrc
              }
            }
          }
        }
      }
    ''';

    final QueryResult result = await _client.query(
      QueryOptions(document: gql(query)),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    return (result.data!['collections']['edges'] as List)
        .map((edge) => edge['node'] as Map<String, dynamic>)
        .toList();
  }
}