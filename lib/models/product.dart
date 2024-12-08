class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final String description;
  final bool isOnSale;
  final double? salePrice;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.description,
    this.isOnSale = false,
    this.salePrice,
  });
}