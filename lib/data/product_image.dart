import 'package:flutter/material.dart';

class ProductImage
{
  final String url;
  final String heroTag;
  final int index;
  final int totalImages;

  const ProductImage({
    required this.url,
    required this.heroTag,
    this.index = 0,
    this.totalImages = 1,
  });
}
