// lib/routes/app_router.dart
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/category_screen.dart';
import '../screens/product_details_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/debug_settings_screen.dart';
import '../models/product.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
        
      case AppRoutes.category:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => CategoryScreen(
              category: args['category'] as String,
              title: args['title'] as String,
              initialProducts: args['initialProducts'] as List<Product>,
            ),
          );
        }
        return _errorRoute();

      case AppRoutes.productDetails:
        if (settings.arguments is String) {
          return MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(
              productId: settings.arguments as String,
            ),
          );
        }
        return _errorRoute();

      case AppRoutes.cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());

      case AppRoutes.checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());

      case AppRoutes.debugSettings:
        return MaterialPageRoute(builder: (_) => const DebugSettingsScreen());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Page not found'),
        ),
      ),
    );
  }
}