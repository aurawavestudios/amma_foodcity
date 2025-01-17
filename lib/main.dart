import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/product.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'screens/home_screen.dart';
import 'onboarding/screens/onboarding_screen.dart';
import 'auth/screens/signup_screen.dart';
import 'auth/screens/login_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'services/data_service.dart';
import 'data/product_data.dart';
import './providers/category_provider.dart';
import './services/shopify_service.dart';

Future<bool> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize DataService first
    await DataService.init();

  // Load initial data
  await ProductsData.loadProducts();

  final shopifyService = ShopifyService();
  
  // Finally load preferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('showHome') ?? false;
  }

class MyApp extends StatefulWidget {
  final bool showHome;
  
  const MyApp({Key? key, required this.showHome}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialized = DataService.isInitialized;
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Amma Foodcity',
      theme: AppTheme.lightTheme,
      home: widget.showHome ? const HomeScreen() : const OnboardingScreen(),
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }

  @override
  void dispose() {
    DataService.closeAll();
    super.dispose();
  }
}

Future<void> retryInitialization() async {
  try {
    final showHome = await initializeApp();
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider(ShopifyService())),
        ],
        child: MyApp(showHome: showHome),
      ),
    );
  } catch (e) {
    print('Retry failed: $e');
  }
}

void main() async {
  try {
    final showHome = await initializeApp();
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ],
        child: MyApp(showHome: showHome),
      ),
    );
  } catch (e, stackTrace) {
    print('Error initializing app: $e');
    print('Stack trace: $stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Error initializing app: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: retryInitialization,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
