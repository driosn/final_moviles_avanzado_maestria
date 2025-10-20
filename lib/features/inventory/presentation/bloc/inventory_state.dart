import 'package:equatable/equatable.dart';

import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/stock_movement.dart';

abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryItem> inventoryItems;

  const InventoryLoaded({required this.inventoryItems});

  @override
  List<Object?> get props => [inventoryItems];
}

class AllProductsWithInventoryLoaded extends InventoryState {
  final List<InventoryItem> allProductsWithInventory;

  const AllProductsWithInventoryLoaded({required this.allProductsWithInventory});

  @override
  List<Object?> get props => [allProductsWithInventory];
}

class StockUpdated extends InventoryState {
  final InventoryItem inventoryItem;

  const StockUpdated({required this.inventoryItem});

  @override
  List<Object?> get props => [inventoryItem];
}

class StockMovementsLoaded extends InventoryState {
  final List<StockMovement> stockMovements;

  const StockMovementsLoaded({required this.stockMovements});

  @override
  List<Object?> get props => [stockMovements];
}

class InventoryError extends InventoryState {
  final String message;

  const InventoryError({required this.message});

  @override
  List<Object?> get props => [message];
}
