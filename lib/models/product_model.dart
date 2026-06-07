// ============================================================
// lib/models/product_model.dart
// ============================================================

enum ProductCategory { animal, food, litterBox, cage }
enum ProductCondition { newItem, used }
enum ProductStatus { active, pending, rejected }

class ProductModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String name;
  final String description;
  final double price;
  final ProductCategory category;
  final ProductCondition condition;
  final ProductStatus status;
  final List<String> imageUrls; // local paths or network urls
  final int stock;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.condition = ProductCondition.newItem,
    this.status = ProductStatus.active,
    required this.imageUrls,
    this.stock = 1,
    required this.createdAt,
  });

  ProductModel copyWith({
    String? name,
    String? description,
    double? price,
    ProductCategory? category,
    ProductCondition? condition,
    ProductStatus? status,
    List<String>? imageUrls,
    int? stock,
  }) {
    return ProductModel(
      id: id,
      sellerId: sellerId,
      sellerName: sellerName,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      imageUrls: imageUrls ?? this.imageUrls,
      stock: stock ?? this.stock,
      createdAt: createdAt,
    );
  }

  String get categoryLabel {
    switch (category) {
      case ProductCategory.animal: return 'Hewan';
      case ProductCategory.food: return 'Makanan';
      case ProductCategory.litterBox: return 'Litter Box';
      case ProductCategory.cage: return 'Kandang';
    }
  }
}