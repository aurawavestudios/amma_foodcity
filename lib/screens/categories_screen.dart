// lib/screens/categories_screen.dart
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../data/product_data.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  static List<Category> categories = [
    Category(
      name: 'Groceries',
      icon: Icons.shopping_basket,
      color: Colors.amber,
      id: 1,
    ),
    Category(
      name: 'Vegetables',
      icon: Icons.eco,
      color: Colors.green,
      id: 2,
    ),
    Category(
      name: 'Fruits',
      icon: Icons.apple,
      color: Colors.red,
      id: 3,
    ),
    Category(
      name: 'Seafood',
      icon: Icons.set_meal,
      color: Colors.blue,
      id: 4,
    ),
    Category(
      name: 'Meat',
      icon: Icons.restaurant_menu,
      color: Colors.redAccent,
      id: 5,
    ),
    Category(
      name: 'Spices',
      icon: Icons.spa,
      color: Colors.purple,
      id: 6
    ),
    Category(
      name: 'Rice',
      icon: Icons.spa,
      color: Colors.purple,
      id: 7
    ),
    Category(
      name: 'Drinks',
      icon: Icons.spa,
      color: Colors.orange,
      id: 8
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/category',
                arguments: {
                  'category': category.name,
                  'title': category.name,
                  'products': ProductsData.getProductsByCategory(category.name),
                },
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: category.color,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}