import '../models/product.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final List<Product> _products = [];
  int _nextId = 1;

  // Initialize with sample data
  void initializeSampleData() {
    if (_products.isEmpty) {
      _products.addAll([
        Product(
          id: _nextId++,
          imageUrl: [
            'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500',
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500',
            'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=500',
          ],
          productName: 'Wireless Headphones',
          price: 99.99,
          discount: 10.0,
          isActive: true,
          width: 15.0,
          length: 20.0,
          weight: 0.3,
          createAt: DateTime.now().subtract(const Duration(days: 5)),
          updateAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Product(
          id: _nextId++,
          imageUrl: [
            'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500',
            'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=500',
            'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=500',
            'https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=500',
          ],
          productName: 'Smart Watch',
          price: 299.99,
          discount: 15.0,
          isActive: true,
          width: 4.0,
          length: 4.5,
          weight: 0.05,
          createAt: DateTime.now().subtract(const Duration(days: 10)),
          updateAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Product(
          id: _nextId++,
          imageUrl: [
            'https://images.unsplash.com/photo-1512149177596-f817c7ef5d4c?w=500',
            'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=500',
            'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=500',
            'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=500',
            'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=500',
          ],
          productName: 'Gaming Laptop',
          price: 1299.99,
          discount: 5.0,
          isActive: true,
          width: 35.0,
          length: 25.0,
          weight: 2.5,
          createAt: DateTime.now().subtract(const Duration(days: 15)),
          updateAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        Product(
          id: _nextId++,
          imageUrl: [
            'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500',
            'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=500',
          ],
          productName: 'Bluetooth Speaker',
          price: 49.99,
          discount: 20.0,
          isActive: false,
          width: 10.0,
          length: 8.0,
          weight: 0.5,
          createAt: DateTime.now().subtract(const Duration(days: 20)),
          updateAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
        Product(
          id: _nextId++,
          imageUrl: [
            'https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=500',
            'https://images.unsplash.com/photo-1594736797933-d0401ba0ad80?w=500',
            'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500',
            'https://images.unsplash.com/photo-1607853202273-797f1c22a38e?w=500',
            'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=500',
            'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=500',
            'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=500',
          ],
          productName: 'Smartphone Pro Max',
          price: 1099.99,
          discount: 8.0,
          isActive: true,
          width: 7.5,
          length: 16.0,
          weight: 0.2,
          createAt: DateTime.now().subtract(const Duration(days: 7)),
          updateAt: DateTime.now(),
        ),
      ]);
    }
  }

  // Get all products
  List<Product> getAllProducts() {
    return List.from(_products);
  }

  // Get product by ID
  Product? getProductById(int id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Add new product
  Product addProduct({
    required List<String> imageUrl,
    required String productName,
    required double price,
    required double discount,
    required bool isActive,
    required double width,
    required double length,
    required double weight,
  }) {
    final now = DateTime.now();
    final product = Product(
      id: _nextId++,
      imageUrl: imageUrl.take(7).toList(), // Limit to 7 images
      productName: productName,
      price: price,
      discount: discount,
      isActive: isActive,
      width: width,
      length: length,
      weight: weight,
      createAt: now,
      updateAt: now,
    );

    _products.add(product);
    return product;
  }

  // Update product
  Product? updateProduct(
    int id, {
    List<String>? imageUrl,
    String? productName,
    double? price,
    double? discount,
    bool? isActive,
    double? width,
    double? length,
    double? weight,
  }) {
    final index = _products.indexWhere((product) => product.id == id);
    if (index == -1) return null;

    final updatedProduct = _products[index].copyWith(
      imageUrl: imageUrl?.take(7).toList(), // Limit to 7 images
      productName: productName,
      price: price,
      discount: discount,
      isActive: isActive,
      width: width,
      length: length,
      weight: weight,
      updateAt: DateTime.now(),
    );

    _products[index] = updatedProduct;
    return updatedProduct;
  }

  // Delete product
  bool deleteProduct(int id) {
    final index = _products.indexWhere((product) => product.id == id);
    if (index == -1) return false;

    _products.removeAt(index);
    return true;
  }

  // Get active products only
  List<Product> getActiveProducts() {
    return _products.where((product) => product.isActive).toList();
  }

  // Search products by name
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return getAllProducts();

    return _products
        .where(
          (product) =>
              product.productName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
