// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/shopify_service.dart';
import '../widgets/promotions_banner.dart';
import '../widgets/category_grid.dart';
import '../widgets/category_section.dart';
import '../widgets/contact_section.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../data/product_data.dart';
import '../models/product.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/category_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  bool _showSearchResults = false;
  bool _isLoading = true;
  String? _error;
  List<Product> _allProducts = [];
  List<Product> _featuredProducts = [];
  List<Product> _newArrivals = [];
  List<Product> _bestSellers = [];

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
  }

  Future<void> _loadAllProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

  // Load all data in parallel
      final results = await Future.wait([
        ProductsData.getFeaturedProducts(),
        ProductsData.getNewArrivals(),
        ProductsData.getBestSellers(),
        ProductsData.getAllProducts(),
      ]);

      setState(() {
        _featuredProducts = results[0];
        _newArrivals = results[1];
        _bestSellers = results[2];
        _allProducts = results[3];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load products. Please try again.';
      });
      print('Error loading data: $e');
    }
  }

   Future<void> _refreshData() async {
    await _loadAllProducts();
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const PromotionsBanner(),
            const CategoryGrid(),
            const SizedBox(height: 16),
            _buildFeaturedSection(),
            _buildNewArrivalsSection(),
            _buildBestSellersSection(),
            const ContactSection(),
          ],
        ),
      ),
    );
  }
  Future<void> _launchWhatsApp() async {
    final Uri url = Uri.parse('https://wa.me/+447459174387');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch WhatsApp');
    }
  }

  Widget _buildFeaturedSection() {
    return CategorySection(
      title: 'Featured Products',
      category: 'Featured',
      products: _featuredProducts,
      onProductTap: (product) => Navigator.pushNamed(
        context,
        '/product-details',
        arguments: product.id,
      ),
    );
  }

  Widget _buildNewArrivalsSection() {
    return CategorySection(
      title: 'New Arrivals',
      category: 'New',
      products: _newArrivals,
      onProductTap: (product) => Navigator.pushNamed(
        context,
        '/product-details',
        arguments: product.id,
      ),
    );
  }

  Widget _buildBestSellersSection() {
    return CategorySection(
      title: 'Best Sellers',
      category: 'Best Sellers',
      products: _bestSellers,
      onProductTap: (product) => Navigator.pushNamed(
        context,
        '/product-details',
        arguments: product.id,
      ),
    );
  }

   Widget _buildSearchResults() {
    final searchResults = _allProducts.where((p) =>
      p.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
      p.description.toLowerCase().contains(_searchController.text.toLowerCase())
    ).toList();

    if (searchResults.isEmpty) {
      return const Center(
        child: Text(
          'No products found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final product = searchResults[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/product-details',
        arguments: product.id,
      ),
      child: Consumer<CartProvider>(
        builder: (ctx, cart, _) => Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImage(product),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _buildPriceSection(product),
                    const SizedBox(height: 8),
                    _buildAddToCartButton(context, product),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF25D366),
        onPressed: _launchWhatsApp,
        child: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('AMMA FoodCity'),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loadAllProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _showSearchResults ? _buildSearchResults() : _buildMainContent(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _showSearchResults = value.isNotEmpty),
        decoration: InputDecoration(
          hintText: 'Search for products...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _showSearchResults
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _showSearchResults = false);
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: Image.network(
            product.imagePath,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Consumer<FavoritesProvider>(
            builder: (ctx, favorites, _) => CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  favorites.isFavorite(product.id) 
                      ? Icons.favorite 
                      : Icons.favorite_border,
                  size: 18,
                  color: favorites.isFavorite(product.id) 
                      ? Colors.red 
                      : Colors.grey,
                ),
                onPressed: () => favorites.toggleFavorite(product.id),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(Product product) {
    if (product.isOnSale && product.salePrice != null) {
      return Row(
        children: [
          Text(
            '£${product.salePrice}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '£${product.price}',
            style: const TextStyle(
              fontSize: 12,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey,
            ),
          ),
        ],
      );
    }
    return Text(
      '£${product.price}',
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context, Product product) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _handleAddToCart(context, product),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: const Text('Add to Cart'),
      ),
    );
  }

  void _handleAddToCart(BuildContext context, Product product) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.addItem(product);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product.name} to cart'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => cart.removeItem(product.id),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
