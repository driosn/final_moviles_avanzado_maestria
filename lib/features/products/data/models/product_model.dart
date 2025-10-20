import '../../domain/entities/product.dart' as domain;

class ProductModel extends domain.Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.category,
    required super.imageUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      imageUrl: json['image_url'] ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory ProductModel.fromEntity(domain.Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      price: product.price,
      category: product.category,
      imageUrl: product.imageUrl,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  domain.Product toEntity() {
    return domain.Product(
      id: id,
      name: name,
      price: price,
      category: category,
      imageUrl: imageUrl,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
