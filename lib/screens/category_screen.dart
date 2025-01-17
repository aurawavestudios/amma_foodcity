// lib/screens/category_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../models/product.dart';
import '../services/shopify_service.dart';
import '../widgets/product_card.dart';
import '../widgets/product_image_carousel.dart';

class CategoryScreen extends StatefulWidget {
  final String category;
  final String title;
  final List<Product> initialProducts;

  const CategoryScreen({
    Key? key,
    required this.category,
    required this.title,
    required this.initialProducts,
  }) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ShopifyService _shopifyService = ShopifyService();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;
  
  // Filter states
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSubCategory = 'All';
  String _sortBy = 'name';
  RangeValues _priceRange = const RangeValues(0, 100);
  bool _onSaleOnly = false;

  @override
  void initState() {
    super.initState();
    _products = widget.initialProducts;
    _refreshProducts();
  }

  Future<void> _refreshProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch updated products from Shopify
      // You might want to add category filtering in the query
      final result = await _shopifyService.getProducts(
        productType: widget.category,
        sortKey: _sortBy,
        isOnSale: _onSaleOnly,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
      );
      
      setState(() {
        _products = result['products'] as List<Product>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load products. Please try again.';
      });
      print('Error loading products: $e');
    }
  }

  List<Product> _getFilteredAndSortedProducts() {
    return _products.where((product) {
      if (_selectedSubCategory != 'All' && 
          product.subCategory != _selectedSubCategory) {
        return false;
      }
      
      if (_searchQuery.isNotEmpty && !_matchesSearch(product)) {
        return false;
      }
      
      return true;
    }).toList()..sort((a, b) {
      switch (_sortBy) {
        case 'price_low':
          return _getEffectivePrice(a).compareTo(_getEffectivePrice(b));
        case 'price_high':
          return _getEffectivePrice(b).compareTo(_getEffectivePrice(a));
        case 'name':
        default:
          return a.name.compareTo(b.name);
      }
    });
  }

  bool _matchesSearch(Product product) {
    final query = _searchQuery.toLowerCase();
    return product.name.toLowerCase().contains(query) ||
           product.description.toLowerCase().contains(query);
  }

  double _getEffectivePrice(Product product) {
    return double.parse(
      product.isOnSale && product.salePrice != null 
        ? product.salePrice! 
        : product.price
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: _buildBody(),
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
              onPressed: _refreshProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: Column(
        children: [
          _buildSearchBar(),
          _buildSubcategoryFilter(),
          _buildSortDropdown(),
          Expanded(child: _buildProductGrid()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: const InputDecoration(
          hintText: 'Search products...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildSubcategoryFilter() {
    final subcategories = ['All', 'Fresh', 'Frozen', 'Packaged', 'Organic'];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: subcategories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              selected: _selectedSubCategory == subcategories[index],
              label: Text(subcategories[index]),
              onSelected: (selected) {
                setState(() => _selectedSubCategory = subcategories[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Text('Sort by: '),
          DropdownButton<String>(
            value: _sortBy,
            items: const [
              DropdownMenuItem(value: 'name', child: Text('Name')),
              DropdownMenuItem(value: 'price_low', child: Text('Price: Low to High')),
              DropdownMenuItem(value: 'price_high', child: Text('Price: High to Low')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _sortBy = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    final filteredProducts = _getFilteredAndSortedProducts();
    
    if (filteredProducts.isEmpty) {
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
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return ProductCard(
          name: product.name,
          price: product.price,
          imagePath: product.imagePath,
          imageUrls: product.imageUrls,
          isOnSale: product.isOnSale,
          salePrice: product.salePrice,
          onTap: () => Navigator.pushNamed(
            context,
            '/product-details',
            arguments: product.id,
          ),
          onAddToCart: () => _handleAddToCart(context, product),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Price Range'),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 100,
                divisions: 20,
                labels: RangeLabels(
                  '£${_priceRange.start.toStringAsFixed(2)}',
                  '£${_priceRange.end.toStringAsFixed(2)}',
                ),
                onChanged: (values) => setSheetState(() => _priceRange = values),
              ),
              SwitchListTile(
                title: const Text('On Sale Only'),
                value: _onSaleOnly,
                onChanged: (value) => setSheetState(() => _onSaleOnly = value),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAddToCart(BuildContext context, Product product) {
    try {
      Provider.of<CartProvider>(context, listen: false).addItem(product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${product.name} to cart'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              Provider.of<CartProvider>(context, listen: false)
                  .removeItem(product.id);
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add item to cart'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}