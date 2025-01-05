import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;
  final Color color;
  final int id;

  const Category({
    required this.name,
    required this.icon,
    required this.color,
    required this.id,
  });
}