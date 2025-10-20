import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_all_products_with_inventory_usecase.dart';
import '../../domain/usecases/get_inventory_by_store_usecase.dart';
import '../../domain/usecases/get_stock_movements_usecase.dart';
import '../../domain/usecases/update_stock_usecase.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GetInventoryByStoreUseCase getInventoryByStoreUseCase;
  final GetAllProductsWithInventoryUseCase getAllProductsWithInventoryUseCase;
  final UpdateStockUseCase updateStockUseCase;
  final GetStockMovementsUseCase getStockMovementsUseCase;

  InventoryBloc({
    required this.getInventoryByStoreUseCase,
    required this.getAllProductsWithInventoryUseCase,
    required this.updateStockUseCase,
    required this.getStockMovementsUseCase,
  }) : super(InventoryInitial()) {
    on<LoadInventoryByStore>(_onLoadInventoryByStore);
    on<LoadAllProductsWithInventory>(_onLoadAllProductsWithInventory);
    on<UpdateStock>(_onUpdateStock);
    on<LoadStockMovements>(_onLoadStockMovements);
  }

  Future<void> _onLoadInventoryByStore(LoadInventoryByStore event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    try {
      final inventoryItems = await getInventoryByStoreUseCase(event.storeId);
      emit(InventoryLoaded(inventoryItems: inventoryItems));
    } catch (e) {
      emit(InventoryError(message: e.toString()));
    }
  }

  Future<void> _onLoadAllProductsWithInventory(LoadAllProductsWithInventory event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());
    try {
      final allProductsWithInventory = await getAllProductsWithInventoryUseCase(event.storeId);
      emit(AllProductsWithInventoryLoaded(allProductsWithInventory: allProductsWithInventory));
    } catch (e) {
      emit(InventoryError(message: e.toString()));
    }
  }

  Future<void> _onUpdateStock(UpdateStock event, Emitter<InventoryState> emit) async {
    try {
      final updatedItem = await updateStockUseCase(event.inventoryItemId, event.newStock, event.reason);
      emit(StockUpdated(inventoryItem: updatedItem));
      // Recargar el inventario
      add(LoadInventoryByStore(storeId: updatedItem.storeId));
    } catch (e) {
      emit(InventoryError(message: e.toString()));
    }
  }

  Future<void> _onLoadStockMovements(LoadStockMovements event, Emitter<InventoryState> emit) async {
    try {
      final stockMovements = await getStockMovementsUseCase(event.inventoryItemId);
      emit(StockMovementsLoaded(stockMovements: stockMovements));
    } catch (e) {
      emit(InventoryError(message: e.toString()));
    }
  }
}
