import 'package:equatable/equatable.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadInventoryByStore extends InventoryEvent {
  final String storeId;

  const LoadInventoryByStore({required this.storeId});

  @override
  List<Object?> get props => [storeId];
}

class LoadAllProductsWithInventory extends InventoryEvent {
  final String storeId;

  const LoadAllProductsWithInventory({required this.storeId});

  @override
  List<Object?> get props => [storeId];
}

class UpdateStock extends InventoryEvent {
  final String inventoryItemId;
  final int newStock;
  final String reason;

  const UpdateStock({required this.inventoryItemId, required this.newStock, required this.reason});

  @override
  List<Object?> get props => [inventoryItemId, newStock, reason];
}

class LoadStockMovements extends InventoryEvent {
  final String inventoryItemId;

  const LoadStockMovements({required this.inventoryItemId});

  @override
  List<Object?> get props => [inventoryItemId];
}
