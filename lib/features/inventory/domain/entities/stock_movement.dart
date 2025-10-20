import 'package:equatable/equatable.dart';

enum StockMovementType { increase, decrease }

class StockMovement extends Equatable {
  final String id;
  final String inventoryItemId;
  final String storeId;
  final String productId;
  final StockMovementType type;
  final int quantity;
  final String reason;
  final DateTime createdAt;
  final String createdBy;

  const StockMovement({
    required this.id,
    required this.inventoryItemId,
    required this.storeId,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.reason,
    required this.createdAt,
    required this.createdBy,
  });

  @override
  List<Object?> get props => [id, inventoryItemId, storeId, productId, type, quantity, reason, createdAt, createdBy];

  StockMovement copyWith({
    String? id,
    String? inventoryItemId,
    String? storeId,
    String? productId,
    StockMovementType? type,
    int? quantity,
    String? reason,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return StockMovement(
      id: id ?? this.id,
      inventoryItemId: inventoryItemId ?? this.inventoryItemId,
      storeId: storeId ?? this.storeId,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
