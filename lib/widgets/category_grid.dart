import 'package:flutter/material.dart';
import 'category_card.dart';
import '../models/category.dart';
import '../screens/category_screen.dart';
import '../data/product_data.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({Key? key}) : super(key: key);

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
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Text(
          'Categories',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      SizedBox(
        height: 160, // Fixed height for horizontal scroll container
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: InkWell(
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
                child: Container(
                  width: 140, // Fixed width for each card
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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
                        const SizedBox(height: 12),
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Explore',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}
}
