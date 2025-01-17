// lib/routes/app_router.dart
import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/category_screen.dart';
import '../screens/product_details_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/main_screen.dart';
import '../onboarding/screens/onboarding_screen.dart';
import '../auth/screens/login_screen.dart';
import '../auth/screens/signup_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    try {
      switch (settings.name) {
        case AppRoutes.onboarding:
          return MaterialPageRoute(
            builder: (_) => const OnboardingScreen(),
          );

        case AppRoutes.signup:
          return MaterialPageRoute(
            builder: (_) => const SignUpScreen(),
          );

        case AppRoutes.login:
          return MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          );

        case AppRoutes.main:
          return MaterialPageRoute(
            builder: (_) => const MainScreen(),
          );

        case AppRoutes.home:
          return MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          );

        case AppRoutes.category:
          final args = settings.arguments as Map<String, dynamic>?;
          if (args == null) {
            throw Exception('Category arguments are required');
          }
          return MaterialPageRoute(
            builder: (_) => CategoryScreen(
              category: args['category'] as String,
              title: args['title'] as String,
              initialProducts: args['products'] ?? [],
            ),
          );

        case AppRoutes.productDetails:
          final productId = settings.arguments as String?;
          if (productId == null) {
            throw Exception('Product ID is required');
          }
          return MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(
              productId: productId,
            ),
          );

        case AppRoutes.cart:
          return MaterialPageRoute(
            builder: (_) => const CartScreen(),
          );

        case AppRoutes.checkout:
          return MaterialPageRoute(
            builder: (_) => const CheckoutScreen(),
          );

        default:
          return _errorRoute(settings.name);
      }
    } catch (e) {
      print('Error generating route: $e');
      return _errorRoute(settings.name);
    }
  }

  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Route not found: ${routeName ?? 'unknown'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(_).pushNamedAndRemoveUntil(
                      AppRoutes.main,
                      (route) => false,
                    );
                  },
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}