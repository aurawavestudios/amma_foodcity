import 'package:flutter/material.dart';

class ProductImageSection extends StatelessWidget {
  final String productId;
  final String imagePath;

  const ProductImageSection({
    Key? key,
    required this.productId,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Hero(
          tag: 'product-$productId',
          child: Image.asset(
            imagePath,
            height: 300,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
        _buildPageIndicators(),
      ],
    );
  }

Widget _buildPageIndicators() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: index == 0 ? 16 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: index == 0 ? Colors.green : Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}