import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/widgets/animated_product_card.dart';
import '/providers/cart_provider.dart';
import '/providers/favorites_provider.dart';
import '/models/product.dart';
import '/data/product_data.dart';
import '../widgets/product_image_carousel.dart';
import '../screens/product_details_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String category;
  final String title;
  final List<Product> products;

  const CategoryScreen({
    Key? key,
    required this.category,
    required this.title,
    required this.products,
  }) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> with SingleTickerProviderStateMixin {
  final GlobalKey _cartIconKey = GlobalKey();
  late AnimationController _filterAnimationController;
  
  String _searchQuery = '';
  String _selectedSubCategory = 'All';
  String _sortBy = 'name';
  RangeValues _priceRange = const RangeValues(0, 100);
  bool _onSaleOnly = false;

  // Improved subcategories map with type safety
  static const Map<String, List<String>> subCategories = {
    'Groceries': ['All', 'Pantry', 'Snacks', 'Breakfast'],
    'Vegetables': ['All', 'Fresh', 'Frozen', 'Organic'],
    'Fruits': ['All', 'Fresh', 'Dried', 'Seasonal'],
    'Seafood': ['All', 'Fresh', 'Frozen', 'Ready to Cook'],
    'Spices': ['All', 'Whole', 'Ground', 'Blends'],
  };

  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _filterAnimationController.dispose();
    super.dispose();
  }

  List<Product> _getFilteredAndSortedProducts() {
    var filteredProducts = ProductsData.getProductsByCategory(widget.category);

    // Apply filters
    filteredProducts = filteredProducts.where((product) {
      if (_selectedSubCategory != 'All' && product.subCategory != _selectedSubCategory) {
        return false;
      }

      if (_searchQuery.isNotEmpty && !_matchesSearch(product)) {
        return false;
      }

      final price = _getEffectivePrice(product);
      if (price < _priceRange.start || price > _priceRange.end) {
        return false;
      }

      if (_onSaleOnly && !product.isOnSale) {
        return false;
      }

      return true;
    }).toList();

    // Sort products
    _sortProducts(filteredProducts);

    return filteredProducts;
  }

  bool _matchesSearch(Product product) {
    final query = _searchQuery.toLowerCase();
    return product.name.toLowerCase().contains(query) ||
           product.description.toLowerCase().contains(query);
  }

  double _getEffectivePrice(Product product) {
    return double.parse(product.isOnSale && product.salePrice != null 
        ? product.salePrice! 
        : product.price);
  }

  void _sortProducts(List<Product> products) {
    switch (_sortBy) {
      case 'name':
        products.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'price_low':
      case 'price_high':
        products.sort((a, b) {
          final priceA = _getEffectivePrice(a);
          final priceB = _getEffectivePrice(b);
          return _sortBy == 'price_low' 
              ? priceA.compareTo(priceB)
              : priceB.compareTo(priceA);
        });
        break;
    }
  }

  void _handleAddToCart(BuildContext context, Product product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    cartProvider.addItem(product);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product.name} to cart'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            // cartProvider.removeSingleItem(product.id);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSubcategoryFilter(),
          _buildSortDropdown(),
          Expanded(
            child: _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.category),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showFilterBottomSheet(context),
        ),
        IconButton(
          key: _cartIconKey,
          icon: const Icon(Icons.shopping_cart),
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search in ${widget.category}...',
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildSubcategoryFilter() {
    final categories = subCategories[widget.category] ?? ['All'];
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              selected: _selectedSubCategory == categories[index],
              label: Text(categories[index]),
              onSelected: (selected) {
                setState(() => _selectedSubCategory = categories[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
  final products = _getFilteredAndSortedProducts();
  
  return GridView.builder(
    padding: const EdgeInsets.all(8),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.7,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    ),
    itemCount: products.length,
    itemBuilder: (context, index) {
      final product = products[index];
      
      return Consumer<FavoritesProvider>(
        builder: (ctx, favoritesProvider, _) {
          return GestureDetector(  // Wrap with GestureDetector
            onTap: () => _navigateToProductDetails(context, product),  // Add navigation
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: SizedBox(
                          height: 125,
                          width: double.infinity,
                          child: ProductImageCarousel(
                            imageUrls: [product.imagePath, ...product.imageUrls],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 16,
                          child: IconButton(
                            icon: Icon(
                              favoritesProvider.isFavorite(product.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 16,
                              color: favoritesProvider.isFavorite(product.id)
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            onPressed: () => favoritesProvider.toggleFavorite(product.id),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                        if (product.isOnSale && product.salePrice != null) ...[
                          Row(
                            children: [
                              Text(
                                '£${product.salePrice}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
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
                          ),
                        ] else
                          Text(
                            '£${product.price}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _handleAddToCart(context, product),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text('Add to Cart'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// Navigation method for product details
void _navigateToProductDetails(BuildContext context, Product product) {
  Navigator.pushNamed(
    context,
    '/product-details',
    arguments: product.id,
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
}