import 'package:flutter/material.dart';
import 'category_card.dart';
import '../models/product_category.dart';
import '../screens/category_screen.dart';
import '../data/product_data.dart';
import '../services/shopify_service.dart';
import '../services/category_service.dart';
import '../services/category_manager.dart';
import '../services/shopify_category_service.dart';

class CategoryGrid extends StatefulWidget {
  const CategoryGrid({Key? key}) : super(key: key);

  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {
  final ShopifyService _shopifyService = ShopifyService();
  late final CategoryManager _categoryManager;
  bool _isLoading = true;
  List<ProductCategory> _categories = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadCategories();
  }

  void _initializeServices() {
  final shopifyClient = _shopifyService.getClient();
  _categoryManager = CategoryManager(ShopifyCategoryService(shopifyClient));
}

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final categories = await _categoryManager.getMainCategories();
      
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('Error loading categories: $e');
    }
  }

  Future<void> _navigateToCategory(ProductCategory category) async {
    try {
      final result = await _shopifyService.getProducts(
        collectionId: category.id,
        first: 20,
      );
      
      if (!mounted) return;

      Navigator.pushNamed(
        context,
        '/category',
        arguments: {
          'category': category.name,
          'title': category.name,
          'initialProducts': result['products'],
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading products: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: _loadCategories,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'No categories found',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Text(
            'Categories',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) => _buildCategoryCard(index),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(int index) {
    final category = _categories[index];
    return InkWell(
      onTap: () => _navigateToCategory(category),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCategoryIcon(category),
            const SizedBox(height: 12),
            Text(
              category.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (category.productCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${category.productCount} items',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(ProductCategory category) {
    if (category.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          category.imageUrl!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(category),
        ),
      );
    }
    return _buildFallbackIcon(category);
  }

  Widget _buildFallbackIcon(ProductCategory category) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: category.color,
          width: 2,
        ),
      ),
      child: Icon(
        category.icon,
        color: category.color,
        size: 30,
      ),
    );
  }
}