import 'package:flutter/material.dart';
import '/widgets/product_image_carousel.dart';

class ProductCard extends StatelessWidget {
 final String name;
 final String price;
 final String imagePath;
 final List<String> imageUrls;
 final bool isOnSale;
 final String? salePrice;
 final VoidCallback onTap;
 final VoidCallback onAddToCart;

 const ProductCard({
   Key? key,
   required this.name,
   required this.price,
   required this.imagePath,
   required this.imageUrls,
   required this.isOnSale,
   this.salePrice,
   required this.onTap,
   required this.onAddToCart,
 }) : super(key: key);

 @override
 Widget build(BuildContext context) => GestureDetector(
   onTap: onTap,
   child: Card(
     elevation: 4,
     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         _buildImage(),
         _buildDetails(),
       ],
     ),
   ),
 );

 Widget _buildImage() => ClipRRect(
   borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
   child: SizedBox(
     height: 150,
     width: double.infinity,
     child: ProductImageCarousel(imageUrls: [imagePath, ...imageUrls]),
   ),
 );

 Widget _buildDetails() => Padding(
   padding: const EdgeInsets.all(8),
   child: Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       _buildName(),
       const SizedBox(height: 4),
       _buildPrice(),
       const SizedBox(height: 8),
       _buildAddToCartButton(),
     ],
   ),
 );

 Widget _buildName() => Text(
   name,
   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
   maxLines: 2,
   overflow: TextOverflow.ellipsis,
 );

 Widget _buildPrice() => isOnSale && salePrice != null
   ? Row(children: [
       Text(
         '£$salePrice',
         style: const TextStyle(
           fontSize: 14,
           color: Colors.green,
           fontWeight: FontWeight.w500,
         ),
       ),
       const SizedBox(width: 4),
       Text(
         '£$price',
         style: const TextStyle(
           fontSize: 12,
           decoration: TextDecoration.lineThrough,
           color: Colors.grey,
         ),
       ),
     ])
   : Text(
       '£$price',
       style: const TextStyle(
         fontSize: 14,
         color: Colors.green,
         fontWeight: FontWeight.w500,
       ),
     );

 Widget _buildAddToCartButton() => SizedBox(
   width: double.infinity,
   child: ElevatedButton(
     onPressed: onAddToCart,
     style: ElevatedButton.styleFrom(
       padding: const EdgeInsets.symmetric(vertical: 8),
     ),
     child: const Text('Add to Cart'),
   ),
 );
}