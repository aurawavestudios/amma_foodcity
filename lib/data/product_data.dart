import '../models/product.dart';
import '../services/shopify_service.dart';

class ProductsData
{
  static final ShopifyService _shopifyService = ShopifyService();
  static final List<Product> _products = [
    Product(
      id: '1',
      name: 'Basmati Rice',
      price: '5.99',
      weight: 1000,  // 1kg in grams
      isOnSale: true,
      salePrice: '4.99',
      imagePath: 'assets/images/products/basmati_rice.jpg',
      imageUrls: [
        'assets/images/products/basmati_rice_1.jpg',
        'assets/images/products/basmati_rice_2.jpg',
      ],
      description: 'Premium quality basmati rice',
      category: 'Groceries',
      categoryId: '1',
      subCategory: 'Pantry',
      origin: 'India',
      storage: 'Store in a cool, dry place',
    ),
    Product(
      id: '2',
      name: 'Almonds',
      price: '9.99',
      weight: 250,  // 250g in grams
      isOnSale: false,
      imagePath: 'assets/images/products/almonds.jpg',
      imageUrls: [
        'assets/images/products/almonds_1.jpg',
        'assets/images/products/almonds_2.jpg',
      ],
      description: 'Crunchy and healthy almonds',
      category: 'Groceries',
      categoryId: '1',
      subCategory: 'Snacks',
      origin: 'USA',
      storage: 'Keep in an airtight container',
    ),
    Product(
      id: '11',
      name: 'Whole Wheat Flour',
      price: '4.99',
      weight: 2000,  // 2kg in grams
      isOnSale: false,
      imagePath: 'assets/images/products/wheat_flour.jpg',
      imageUrls: [
        'assets/images/products/wheat_flour_1.jpg',
        'assets/images/products/wheat_flour_2.jpg',
      ],
      description: '100% whole wheat flour, perfect for baking.',
      category: 'Groceries',
      categoryId: '1',
      subCategory: 'Pantry',
      origin: 'India',
      storage: 'Store in a cool, dry place',
    ),
    Product(
      id: '12',
      name: 'Bananas',
      price: '1.49',
      weight: 1000,  // 1kg in grams
      isOnSale: true,
      salePrice: '0.99',
      imagePath: 'assets/images/products/bananas.jpg',
      imageUrls: [
        'assets/images/products/bananas_1.jpg',
        'assets/images/products/bananas_2.jpg',
      ],
      description: 'Sweet and ripe bananas.',
      category: 'Fruits',
      categoryId: '2',
      subCategory: 'Fresh',
      origin: 'Ecuador',
      storage: 'Refrigerate for longer shelf life',
    ),
    Product(
      id: '13',
      name: 'Cashew Nuts',
      price: '10.99',
      weight: 200,  // 200g in grams
      isOnSale: true,
      salePrice: '8.99',
      imagePath: 'assets/images/products/cashews.jpg',
      imageUrls: [
        'assets/images/products/cashews_1.jpg',
        'assets/images/products/cashews_2.jpg',
      ],
      description: 'Premium roasted cashew nuts.',
      category: 'Groceries',
      categoryId: '1',
      subCategory: 'Snacks',
      origin: 'Vietnam',
      storage: 'Store in an airtight container',
    ),
    Product(
      id: '14',
      name: 'Cherry Tomatoes',
      price: '2.99',
      weight: 500,  // 500g in grams
      isOnSale: false,
      imagePath: 'assets/images/products/cherry_tomatoes.jpg',
      imageUrls: [
        'assets/images/products/cherry_tomatoes_1.jpg',
        'assets/images/products/cherry_tomatoes_2.jpg',
      ],
      description: 'Juicy and fresh cherry tomatoes.',
      category: 'Vegetables',
      categoryId: '3',
      subCategory: 'Fresh',
      origin: 'Italy',
      storage: 'Refrigerate to maintain freshness',
    ),
    // Add more products in the same format...
  ];

  static List<Product> getAllProducts()
{
    return _products;
  }

  static Product? getProductById(String id)
{
    try
{
      return _products.firstWhere((product) => product.id == id);
    } catch (e)
{
      return null;
    }
  }

  static List<Product> getProductsByCategory(String category)
{
    return _products
        .where((product) => product.category == category)
        .toList();
  }

  static List<Product> getProductsBySubCategory(String category, String subCategory)
{
    return _products
        .where((product) =>
            product.category == category && product.subCategory == subCategory)
        .toList();
  }

  static List<Product> getOnSaleProducts()
{
    return _products
        .where((product) => product.isOnSale)
        .toList();
  }

  // Add these methods to your ProductsData class in product_data.dart
static List<Product> getFeaturedProducts()
{
  return _products.where((product) => 
    product.isOnSale || product.category == 'Featured').toList();
}

static List<Product> getNewArrivals()
{
  // Return the most recently added products (last 4)
  return _products.reversed.take(4).toList();
}

static List<Product> getBestSellers()
{
  // For demo, return products with sale price
  return _products.where((product) => product.isOnSale).toList();
}

}
