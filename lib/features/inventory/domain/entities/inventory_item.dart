import 'package:equatable/equatable.dart';

import '../../../products/domain/entities/product.dart';

class InventoryItem extends Equatable {
  final String id;
  final String storeId;
  final String productId;
  final Product product;
  final int stock;
  final int minStock;
  final DateTime lastUpdated;
  final String updatedBy;

  const InventoryItem({
    required this.id,
    required this.storeId,
    required this.productId,
    required this.product,
    required this.stock,
    required this.minStock,
    required this.lastUpdated,
    required this.updatedBy,
  });

  @override
  List<Object?> get props => [id, storeId, productId, product, stock, minStock, lastUpdated, updatedBy];

  InventoryItem copyWith({
    String? id,
    String? storeId,
    String? productId,
    Product? product,
    int? stock,
    int? minStock,
    DateTime? lastUpdated,
    String? updatedBy,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  bool get isLowStock => stock <= minStock;
  bool get isOutOfStock => stock == 0;
}
