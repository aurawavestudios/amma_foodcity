import 'package:flutter/material.dart';

class CategoryScreen extends StatelessWidget {
  final String category;

  const CategoryScreen({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
      ),
      body: const Center(
        child: Text('Category Screen - Implementation pending'),
      ),
    );
  }
}