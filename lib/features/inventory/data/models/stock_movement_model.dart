import '../../domain/entities/stock_movement.dart' as domain;

class StockMovementModel extends domain.StockMovement {
  const StockMovementModel({
    required super.id,
    required super.inventoryItemId,
    required super.storeId,
    required super.productId,
    required super.type,
    required super.quantity,
    required super.reason,
    required super.createdAt,
    required super.createdBy,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      id: json['id'] as String,
      inventoryItemId: json['inventory_item_id'] as String,
      storeId: json['store_id'] as String,
      productId: json['product_id'] as String,
      type: domain.StockMovementType.values.firstWhere((e) => e.toString() == 'StockMovementType.${json['type']}'),
      quantity: json['quantity'] as int,
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String,
    );
  }

  factory StockMovementModel.fromEntity(domain.StockMovement stockMovement) {
    return StockMovementModel(
      id: stockMovement.id,
      inventoryItemId: stockMovement.inventoryItemId,
      storeId: stockMovement.storeId,
      productId: stockMovement.productId,
      type: stockMovement.type,
      quantity: stockMovement.quantity,
      reason: stockMovement.reason,
      createdAt: stockMovement.createdAt,
      createdBy: stockMovement.createdBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inventory_item_id': inventoryItemId,
      'store_id': storeId,
      'product_id': productId,
      'type': type.toString().split('.').last,
      'quantity': quantity,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
    };
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'inventory_item_id': inventoryItemId,
      'store_id': storeId,
      'product_id': productId,
      'type': type.toString().split('.').last,
      'quantity': quantity,
      'reason': reason,
      'created_by': createdBy,
    };
  }

  domain.StockMovement toEntity() {
    return domain.StockMovement(
      id: id,
      inventoryItemId: inventoryItemId,
      storeId: storeId,
      productId: productId,
      type: type,
      quantity: quantity,
      reason: reason,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }
}
