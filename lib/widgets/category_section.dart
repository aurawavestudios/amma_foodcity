import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../data/product_data.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import 'product_image_carousel.dart';
import '../routes/app_routes.dart';
import '../widgets/product_card.dart';

class CategorySection extends StatelessWidget {
  final String title;
  final String category;
  final List<Product> products;
  final void Function(Product) onProductTap;

  const CategorySection({
    Key? key, 
    required this.title,
    required this.category, 
    required this.products,
    required this.onProductTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        _buildProductsList(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          TextButton(
            onPressed: () => Navigator.pushNamed(
              context, 
              AppRoutes.category,
              arguments: {
                'category': category,
                'title': title,
                'products': ProductsData.getProductsByCategory(category),
              },
            ),
            child: const Text('See All'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: products.length > 4 ? 4 : products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return SizedBox(
            width: 180,
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: ProductCard(
                name: product.name,
                price: product.price,
                imagePath: product.imagePath,
                imageUrls: product.imageUrls,
                isOnSale: product.isOnSale,
                salePrice: product.salePrice,
                onTap: () => onProductTap(product),
                onAddToCart: () => _handleAddToCart(context, product),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleAddToCart(BuildContext context, Product product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addItem(product);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${product.name} to cart'),
        duration: const Duration(seconds: 2),
        // action: SnackBarAction(
        //   label: 'UNDO',
        //   onPressed: () => cartProvider.removeSingleItem(product.id),
        // ),
      ),
    );
  }
}