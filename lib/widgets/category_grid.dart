import 'package:flutter/material.dart';
import 'category_card.dart';
import '../models/category.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({Key? key}) : super(key: key);

  static final List<Category> categories = [
    Category(name: 'Groceries', image: 'assets/images/groceries.jpg', id: '1'),//Icons.shopping_basket
    Category(name: 'Vegetables', image: 'assets/images/vegetables.jpg', id: '2'),
    Category(name: 'Fruits', image: 'assets/images/fruits.jpg', id: '3'),
    Category(name: 'Seafood', image: 'assets/images/seafood.jpg', id: '4'),
    Category(name: 'Meat', image: 'assets/images/meat.jpg', id: '5'),
    Category(name: 'Spices', image: 'assets/images/spices.jpg', id: '6'),
    Category(name: 'Rice', image: 'assets/images/rice.jpg', id: '7'),
    Category(name: 'Drinks', image: 'assets/images/softdrinks.jpg', id: '8'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return CategoryCard(
            title: categories[index].name!,
            imageUrl: categories[index].image!,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/category',
                arguments: categories[index].name,
              );
            },
          );
        },
      ),
    );
  }
}
