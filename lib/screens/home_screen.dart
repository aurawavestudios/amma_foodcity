// lib/screens/home_screen.dart (Updated version)
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widgets/promotions_banner.dart';
import '../widgets/category_grid.dart';
import '../widgets/featured_products.dart';
import '../widgets/contact_section.dart';
import '../widgets/category_section.dart';
import '../widgets/product_card.dart';

import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';

import '../widgets/product_image_carousel.dart';
import '../data/product_data.dart';
import '../models/product.dart';

class HomeScreen extends StatefulWidget
{
 const HomeScreen({Key? key}) : super(key: key);

 @override
 State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
{
 final _searchController = TextEditingController();
 bool _showSearchResults = false;

 Future<void> _launchWhatsApp() async
{
  try
{
    if (!await launchUrl(
      Uri.parse("https://wa.me/+447459174387"), 
      mode: LaunchMode.externalApplication
))
{
      throw Exception('Could not launch WhatsApp');
    }
  } catch (e)
{
    debugPrint('Error launching WhatsApp: $e');
  }
}

 @override
 Widget build(BuildContext context) => Scaffold(
   appBar: _buildAppBar(),
   body: Column(children: [
     _buildSearchBar(),
     Expanded(child: _showSearchResults ? _buildSearchResults() : _buildMainContent())
   ]),
   floatingActionButton: FloatingActionButton(
     backgroundColor: const Color(0xFF25D366),
     onPressed: _launchWhatsApp,
     child: const Icon(FontAwesomeIcons.whatsapp, color: Colors.white),
   ),
 );

 PreferredSizeWidget _buildAppBar() => AppBar(
   title: const Text('Amma FoodCity'),
   actions: [
     IconButton(
       icon: const Icon(Icons.shopping_cart),
       onPressed: () => Navigator.pushNamed(context, '/cart'),
     ),
   ],
 );

 Widget _buildSearchBar() => Padding(
   padding: const EdgeInsets.all(16),
   child: TextField(
     controller: _searchController,
     onChanged: (value) => setState(() => _showSearchResults = value.isNotEmpty),
     decoration: InputDecoration(
       hintText: 'Search for products...',
       prefixIcon: const Icon(Icons.search),
       suffixIcon: _showSearchResults ? IconButton(
         icon: const Icon(Icons.clear),
         onPressed: ()
{
           _searchController.clear();
           setState(() => _showSearchResults = false);
         },
       ) : null,
       border: OutlineInputBorder(
         borderRadius: BorderRadius.circular(25),
         borderSide: BorderSide(color: Theme.of(context).primaryColor),
       ),
       filled: true,
       fillColor: Colors.white,
     ),
   ),
 );

 Widget _buildMainContent() => SingleChildScrollView(
   child: Column(children: [
     const PromotionsBanner(),
     const CategoryGrid(),
     const SizedBox(height: 16),
     CategorySection(
       title: 'Featured Products',
       category: 'Featured',
       products: ProductsData.getFeaturedProducts(),
       onProductTap: (product) => Navigator.pushNamed(
         context,
         '/product-details',
         arguments: product.id,
       ),
     ),
     CategorySection(
       title: 'New Arrivals',
       category: 'New', 
       products: ProductsData.getNewArrivals(),
       onProductTap: (product) => Navigator.pushNamed(
         context,
         '/product-details',
         arguments: product.id,
       ),
     ),
     CategorySection(
       title: 'Best Sellers',
       category: 'Best Sellers',
       products: ProductsData.getBestSellers(),
       onProductTap: (product) => Navigator.pushNamed(
         context,
         '/product-details',
         arguments: product.id,
       ),
     ),
     const ContactSection(),
   ]),
 );

// Update the _buildSearchResults method
Widget _buildSearchResults()
{
  final searchResults = ProductsData.getAllProducts()
      .where((p) => p.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                   p.description.toLowerCase().contains(_searchController.text.toLowerCase()))
      .toList();

  if (searchResults.isEmpty)
{
    return const Center(
      child: Text(
        'No products found',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  return GridView.builder(
    padding: const EdgeInsets.all(8),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.7,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
    ),
    itemCount: searchResults.length,
    itemBuilder: (context, index)
{
      final product = searchResults[index];
      
      return Consumer<FavoritesProvider>(
        builder: (ctx, favoritesProvider, _)
{
          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/product-details',
              arguments: product.id,
            ),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: SizedBox(
                          height: 125,
                          width: double.infinity,
                          child: ProductImageCarousel(
                            imageUrls: [product.imagePath, ...product.imageUrls],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 16,
                          child: IconButton(
                            icon: Icon(
                              favoritesProvider.isFavorite(product.id)
? Icons.favorite
: Icons.favorite_border,
                              size: 16,
                              color: favoritesProvider.isFavorite(product.id)
? Colors.red
: Colors.grey,
                            ),
                            onPressed: () => favoritesProvider.toggleFavorite(product.id),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (product.isOnSale && product.salePrice != null) ...[
                          Row(
                            children: [
                              Text(
                                '£${product.salePrice}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '£${product.price}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ] else
                          Text(
                            '£${product.price}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _handleAddToCart(context, product),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text('Add to Cart'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// Add method to handle adding to cart
void _handleAddToCart(BuildContext context, Product product)
{
  final cartProvider = Provider.of<CartProvider>(context, listen: false);
  cartProvider.addItem(product);
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Added ${product.name} to cart'),
      duration: const Duration(seconds: 2),
      // action: SnackBarAction(
      //   label: 'UNDO',
      //   // onPressed: () => cartProvider.removeSingleItem(product.id),
      // ),
    ),
  );
}
}
