// lib/routes/app_router.dart
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/category_screen.dart';
import '../screens/product_details_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../models/product.dart';
import 'app_routes.dart';

class AppRouter
{
  static Route<dynamic> generateRoute(RouteSettings settings)
{
    switch (settings.name)
{
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case AppRoutes.category:
        final arguments = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CategoryScreen(
            category: arguments['category'] as String,
            title: arguments['title'] as String,
            products: arguments['products'] as List<Product>,
          ),
        );
      
      case AppRoutes.productDetails:
        return MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(
            productId: settings.arguments as String,
          ),
        );
      
      case AppRoutes.cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      
      case AppRoutes.checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
