class Product {
  final int id;
  final List<String> imageUrl;
  final String productName;
  final double price;
  final double discount;
  final bool isActive;
  final double width;
  final double length;
  final double weight;
  final DateTime createAt;
  final DateTime updateAt;

  Product({
    required this.id,
    required this.imageUrl,
    required this.productName,
    required this.price,
    required this.discount,
    required this.isActive,
    required this.width,
    required this.length,
    required this.weight,
    required this.createAt,
    required this.updateAt,
  });

  // Get discounted price
  double get discountedPrice => price - (price * discount / 100);

  // Copy with method for updating
  Product copyWith({
    int? id,
    List<String>? imageUrl,
    String? productName,
    double? price,
    double? discount,
    bool? isActive,
    double? width,
    double? length,
    double? weight,
    DateTime? createAt,
    DateTime? updateAt,
  }) {
    return Product(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      discount: discount ?? this.discount,
      isActive: isActive ?? this.isActive,
      width: width ?? this.width,
      length: length ?? this.length,
      weight: weight ?? this.weight,
      createAt: createAt ?? this.createAt,
      updateAt: updateAt ?? this.updateAt,
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'productName': productName,
      'price': price,
      'discount': discount,
      'isActive': isActive,
      'width': width,
      'length': length,
      'weight': weight,
      'createAt': createAt.toIso8601String(),
      'updateAt': updateAt.toIso8601String(),
    };
  }

  // Create from Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? 0,
      imageUrl: List<String>.from(map['imageUrl'] ?? []),
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      isActive: map['isActive'] ?? true,
      width: (map['width'] ?? 0).toDouble(),
      length: (map['length'] ?? 0).toDouble(),
      weight: (map['weight'] ?? 0).toDouble(),
      createAt: DateTime.parse(map['createAt']),
      updateAt: DateTime.parse(map['updateAt']),
    );
  }
}
