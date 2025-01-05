import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductInfoSection extends StatelessWidget {
  final Product product;

  const ProductInfoSection({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleAndFavorite(),
          _buildWeightAndPrice(),
          const SizedBox(height: 16),
          _buildQuantityAndPrice(),
          const SizedBox(height: 24),
          _buildProductDetails(),
          _buildReviewSection(),
        ],
      ),
    );
  }

  Widget _buildTitleAndFavorite() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.favorite_border,
            color: Colors.black,
          ),
          onPressed: () {
            // Toggle favorite
          },
        ),
      ],
    );
  }

  Widget _buildWeightAndPrice() {
    return Text(
      '1kg, Price',
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 16,
      ),
    );
  }

  Widget _buildQuantityAndPrice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuantitySelector(),
        Text(
          '\$${product.price}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () {
              // Decrease quantity
            },
          ),
          const Text(
            '1',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.green,
            ),
            onPressed: () {
              // Increase quantity
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    return ExpansionTile(
      title: const Text(
        'Product Details',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Text(
            product.description,
            style: TextStyle(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        'Review',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: List.generate(
              5,
              (index) => const Icon(
                Icons.star,
                color: Colors.orange,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}