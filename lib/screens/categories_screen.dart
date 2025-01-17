// lib/screens/categories_screen.dart
import 'package:flutter/material.dart';
import '../models/product_category.dart';
import '../services/shopify_service.dart';
import '../services/category_service.dart';
import '../services/category_manager.dart';
import '../services/shopify_category_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ShopifyService _shopifyService = ShopifyService();
  late final CategoryManager _categoryManager;
  bool _isLoading = true;
  String? _error;
  List<ProductCategory> _categories = [];


  @override
  void initState() {
    super.initState();
    _CategoriesScreenState();
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
        _error = 'Failed to load categories: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCategories,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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
        child: Text('No categories found'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _buildCategoryCard(context, category);
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, ProductCategory category) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/category',
          arguments: {
            'category': category.name,
            'title': category.name,
            'initialProducts': [],  // Products will be loaded in CategoryScreen
          },
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCategoryImage(category),
            const SizedBox(height: 12),
            _buildCategoryTitle(category),
            if (category.subCategories != null && category.subCategories!.isNotEmpty)
              _buildSubcategoriesCount(category),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryImage(ProductCategory category) {
    if (category.imageUrl != null) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Image.network(
          category.imageUrl!,
          height: 100,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildCategoryIcon(category);
          },
        ),
      );
    }
    return _buildCategoryIcon(category);
  }

  Widget _buildCategoryIcon(ProductCategory category) {
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

  Widget _buildCategoryTitle(ProductCategory category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        category.name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSubcategoriesCount(ProductCategory category) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '${category.subCategories!.length} subcategories',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}