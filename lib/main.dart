// lib/main.dart
import 'package:flutter/material.dart';
import 'models/product.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
j
// Import all screens
import 'screens/main_screen.dart';
import 'screens/home_screen.dart';
import 'onboarding/screens/onboarding_screen.dart';
import 'auth/screens/signup_screen.dart';
import 'auth/screens/login_screen.dart';
import 'screens/category_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';

import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final showHome = prefs.getBool('showHome') ?? false;
  
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => FavoritesProvider()),
    ],
    child: MyApp(showHome: showHome),
  ));
}

class MyApp extends StatefulWidget
{
  final bool showHome;
  
  const MyApp({Key? key, required this.showHome}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
{
  List<Product> productsList = [];

  @override
  void initState()
{
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async
{
    // Implement the logic to fetch products, either from an API or local database.
    // Once products are fetched, update the productsList and state.
    final products = await fetchProducts(); // Your fetching method here
    setState(()
{
      productsList = products;
    });
  }

  Future<List<Product>> fetchProducts() async
{
    // Example: Fetch data from a local JSON file or API.
    // Replace this with your actual product loading logic.
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return []; // Return the list of products here
  }

  @override
  Widget build(BuildContext context)
{
    return MaterialApp(
      title: 'Amma Foodcity',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.onboarding,
      onGenerateRoute: AppRouter.generateRoute,
      routes: 
{
        AppRoutes.onboarding:(context) => const OnboardingScreen(),
        AppRoutes.signup:(context) => const SignUpScreen(),
        AppRoutes.login:(context) => const LoginScreen(),
        AppRoutes.main:(context) => const MainScreen(),
        AppRoutes.home:(context) => const HomeScreen(),
      },
    );
  }
}
