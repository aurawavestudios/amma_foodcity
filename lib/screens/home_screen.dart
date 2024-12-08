import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/promotions_banner.dart';
import '../widgets/category_grid.dart';
import '../widgets/featured_products.dart';
import '../widgets/contact_section.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  Future<void> launchWhatsApp() async {
    const whatsappUrl = "https://wa.me/+447459174387";  // Replace with your WhatsApp number
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amma FoodCity'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Promotions Banner
            PromotionsBanner(),
            
            // Categories Grid
            CategoryGrid(),
            
            // Featured Products
            FeaturedProducts(),
            
            // Contact Section
            ContactSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(FontAwesomeIcons.whatsapp),
        onPressed: () {
          // Launch WhatsApp chat
          launchWhatsApp();
        },
      ),
    );
  }
}