// lib/screens/product_details_screen.dart
import 'package:flutter/material.dart';
import '/data/product_data.dart';
import '/models/product.dart';
import '/widgets/product_app_bar.dart';
import '/widgets/product_info_section.dart';
import '/widgets/add_to_cart_button.dart';
import '/widgets/product_image_carousel.dart';
// Remove duplicate ProductImage import

class ProductDetailsScreen extends StatelessWidget {
  final String productId;

  const ProductDetailsScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = ProductsData.getProductById(productId);

    if (product == null) {
      return _buildErrorScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ProductAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: ProductImageCarousel(
                      imageUrls: product.allImages,
                    ),
                  ),
                  ProductInfoSection(product: product),
                ],
              ),
            ),
          ),
          const AddToCartButton(),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Not Found'),
      ),
      body: const Center(
        child: Text('The requested product could not be found.'),
      ),
    );
  }
}