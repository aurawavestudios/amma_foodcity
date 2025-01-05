// lib/widgets/product_image_carousel.dart
import 'package:flutter/material.dart';
import '/widgets/network_image_handler.dart';

class ProductImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const ProductImageCarousel({
    Key? key,
    required this.imageUrls,
  }) : super(key: key);

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        NetworkImageHandler(
          imageUrl: widget.imageUrls[currentIndex],
          heroTag: 'product_${widget.imageUrls[currentIndex]}',
          height: 300,
          width: double.infinity,
          fit: BoxFit.contain,
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
          widget.imageUrls.length,
          (index) => _buildIndicatorDot(index),
        ),
      ),
    );
  }

  Widget _buildIndicatorDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: index == currentIndex ? 16 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: index == currentIndex ? Colors.green : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}