import 'package:flutter/material.dart';
import 'product_card.dart';

class FeaturedProducts extends StatelessWidget {
  FeaturedProducts({Key? key}) : super(key: key);  // Removed const

  final List<Map<String, String>> products = [      // Removed const for flexibility
    {
      'name': 'Wine',
      'price': '2.99',
      'imagePath': 'assets/images/products/wine.jpg',
    },
    {
      'name': 'Beer',
      'price': '1.99',
      'imagePath': 'assets/images/products/famous.jpg',
    },
    {
      'name': 'Vodka',
      'price': '3.99',
      'imagePath': 'assets/images/products/vodka.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured Products',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ProductCard(
                    name: products[index]['name'].toString(),
                    price: products[index]['price'].toString(),
                    imagePath: products[index]['imagePath'].toString(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}