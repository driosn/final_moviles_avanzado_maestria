import '../../../products/data/models/product_model.dart';
import '../../domain/entities/inventory_item.dart' as domain;

class InventoryItemModel extends domain.InventoryItem {
  const InventoryItemModel({
    required super.id,
    required super.storeId,
    required super.productId,
    required super.product,
    required super.stock,
    required super.minStock,
    required super.lastUpdated,
    required super.updatedBy,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'] as String,
      storeId: json['store_id'] ?? '',
      productId: json['product_id'] ?? '',
      product: ProductModel.fromJson(json['products'] as Map<String, dynamic>),
      stock: json['stock'] ?? 0,
      minStock: json['min_stock'] ?? 0,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      updatedBy: json['updated_by'] ?? '',
    );
  }

  factory InventoryItemModel.fromEntity(domain.InventoryItem inventoryItem) {
    return InventoryItemModel(
      id: inventoryItem.id,
      storeId: inventoryItem.storeId,
      productId: inventoryItem.productId,
      product: inventoryItem.product,
      stock: inventoryItem.stock,
      minStock: inventoryItem.minStock,
      lastUpdated: inventoryItem.lastUpdated,
      updatedBy: inventoryItem.updatedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'product_id': productId,
      'stock': stock,
      'min_stock': minStock,
      'last_updated': lastUpdated.toIso8601String(),
      'updated_by': updatedBy,
    };
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'store_id': storeId,
      'product_id': productId,
      'stock': stock,
      'min_stock': minStock,
      'last_updated': DateTime.now().toIso8601String(),
      'updated_by': updatedBy,
    };
  }

  domain.InventoryItem toEntity() {
    return domain.InventoryItem(
      id: id,
      storeId: storeId,
      productId: productId,
      product: product,
      stock: stock,
      minStock: minStock,
      lastUpdated: lastUpdated,
      updatedBy: updatedBy,
    );
  }
}
