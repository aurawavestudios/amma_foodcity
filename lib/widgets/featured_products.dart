// lib/widgets/featured_products.dart
import 'package:flutter/material.dart';
import '/widgets/product_card.dart';
import '/data/product_data.dart';
import '../models/product.dart';

class FeaturedProducts extends StatelessWidget {
  const FeaturedProducts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Product> products = ProductsData.getAllProducts().take(5).toList();

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 200,
              child: ProductCard(
                name: product.name,
                price: product.price,
                imagePath: product.imagePath,
                imageUrls: product.imageUrls,
                isOnSale: product.isOnSale,
                salePrice: product.salePrice,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/product-details',
                    arguments: product.id,
                  );
                },
                onAddToCart: () {
                  // Handle add to cart
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added ${product.name} to cart'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}