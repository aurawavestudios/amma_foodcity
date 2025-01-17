// lib/config/shopify_config.dart
class ShopifyConfig {
  // Basic Configuration
  static const String shopDomain = 'khb11m-aw.myshopify.com';
  static const String storefrontAccessToken = '602cf40738a3ccd7928d4794fef0e263';
  static const String apiVersion = '2024-01';

  // API URLs
  static String get storefrontUrl => 'https://$shopDomain/api/$apiVersion/graphql.json';
  static String get adminUrl => 'https://$shopDomain/admin/api/$apiVersion';

  // Cache Configuration
  static const int cacheTimeInMinutes = 5;
  static const bool enableOfflineCache = true;

  // API Limits
  static const int productsPerPage = 20;
  static const int collectionsPerPage = 20;

  // Feature Flags
  static const bool enableCustomerAccounts = false;
  static const bool enableWishlist = true;
  static const bool enableReviews = false;
}