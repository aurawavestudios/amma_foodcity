// lib/models/product.dart
class Product
{
  final String id;
  final String name;
  final String price;
  final String? salePrice;
  final int weight;
  final bool isOnSale;
  final String imagePath;
  final List<String> imageUrls;
  final String description;
  final String category;
  final String categoryId;
  final String subCategory;
  final String origin;
  final String storage;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.weight,
    this.salePrice,
    required this.isOnSale,
    required this.imagePath,
    required this.imageUrls,
    required this.description,
    required this.category,
    required this.categoryId,
    required this.subCategory,
    required this.origin,
    required this.storage,
  });

  List<String> get allImages => [imagePath, ...imageUrls];

  Map<String, dynamic> toMap()
{
    return
{
      'id': id,
      'name': name,
      'price': price,
      'weight': weight,
      'salePrice': salePrice,
      'isOnSale': isOnSale,
      'imagePath': imagePath,
      'imageUrls': List<String>.from(imageUrls),
      'description': description,
      'category': category,
      'categoryId': categoryId,
      'subCategory': subCategory,
      'origin': origin,
      'storage': storage,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json)
{
  return Product(
    id: json['id'] as String,
    name: json['name'] as String,
    price: json['price'] as String,
    weight: json['weight'] as int,
    salePrice: json['salePrice'] as String?,
    isOnSale: json['isOnSale'] as bool,
    imagePath: json['imagePath'] as String,
    imageUrls: List<String>.from(json['imageUrls'] ?? []),
    description: json['description'] as String,
    category: json['category'] as String,
    categoryId: json['categoryId'] as String,
    subCategory: json['subCategory'] as String,
    origin: json['origin'] as String,
    storage: json['storage'] as String,
  );
}

 Map<String, dynamic> toJson()
{
  return
{
    'id': id,
    'name': name,
    'price': price,
    'weight': weight,
    'salePrice': salePrice,
    'isOnSale': isOnSale,
    'imagePath': imagePath,
    'imageUrls': imageUrls,
    'description': description,
    'category': category,
    'categoryId': categoryId,
    'subCategory': subCategory,
    'origin': origin,
    'storage': storage,
  };
}
}
