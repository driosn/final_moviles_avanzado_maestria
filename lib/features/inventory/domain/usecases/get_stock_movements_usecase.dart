import '../entities/stock_movement.dart';
import '../repositories/inventory_repository.dart';

class GetStockMovementsUseCase {
  final InventoryRepository repository;

  GetStockMovementsUseCase({required this.repository});

  Future<List<StockMovement>> call(String inventoryItemId) async {
    return await repository.getStockMovements(inventoryItemId);
  }
}
