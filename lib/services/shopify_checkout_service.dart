// lib/services/shopify_checkout_service.dart
import 'package:graphql_flutter/graphql_flutter.dart';
import '../providers/cart_provider.dart';

class ShopifyCheckoutService {
  final GraphQLClient _client;

  ShopifyCheckoutService(this._client);

  Future<String> createCheckout(Map<String, CartItem> items) async {
    const String mutation = r'''
      mutation checkoutCreate($input: CheckoutCreateInput!) {
        checkoutCreate(input: $input) {
          checkout {
            id
            webUrl
            totalPrice {
              amount
              currencyCode
            }
          }
          checkoutUserErrors {
            code
            field
            message
          }
        }
      }
    ''';

    // Convert cart items to Shopify line items
    final lineItems = items.values.map((item) => {
      'variantId': item.id,
      'quantity': item.quantity,
    }).toList();

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'input': {
          'lineItems': lineItems,
        },
      },
    );

    final QueryResult result = await _client.mutate(options);

    if (result.hasException) {
      throw result.exception!;
    }

    final checkoutData = result.data!['checkoutCreate'];
    final errors = checkoutData['checkoutUserErrors'] as List;

    if (errors.isNotEmpty) {
      throw Exception(errors.first['message']);
    }

    // Return the checkout URL for web checkout
    return checkoutData['checkout']['webUrl'] as String;
  }

  Future<void> updateCheckout({
    required String checkoutId,
    required String email,
    required ShippingAddress address,
  }) async {
    const String mutation = r'''
      mutation checkoutEmailUpdate($checkoutId: ID!, $email: String!) {
        checkoutEmailUpdate(checkoutId: $checkoutId, email: $email) {
          checkout {
            id
            email
          }
          checkoutUserErrors {
            code
            field
            message
          }
        }
      }
    ''';

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'checkoutId': checkoutId,
        'email': email,
      },
    );

    final QueryResult result = await _client.mutate(options);

    if (result.hasException) {
      throw result.exception!;
    }

    // Handle shipping address update similarly
    // You'll need another mutation for shipping address
  }

  Future<void> completeCheckoutWithCreditCard({
    required String checkoutId,
    required CreditCard creditCard,
  }) async {
    // Implement credit card payment
    // This usually involves a third-party payment processor
    // You might want to use Stripe or another payment gateway
    throw UnimplementedError(
      'Credit card checkout needs to be implemented with a payment processor'
    );
  }
}

class ShippingAddress {
  final String address1;
  final String? address2;
  final String city;
  final String country;
  final String zip;
  final String firstName;
  final String lastName;
  final String phone;

  ShippingAddress({
    required this.address1,
    this.address2,
    required this.city,
    required this.country,
    required this.zip,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
    'address1': address1,
    'address2': address2,
    'city': city,
    'country': country,
    'zip': zip,
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
  };
}

class CreditCard {
  final String number;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final String name;

  CreditCard({
    required this.number,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    required this.name,
  });
}