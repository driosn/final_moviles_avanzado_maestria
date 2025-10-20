import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class UpdateStockUseCase {
  final InventoryRepository repository;

  UpdateStockUseCase({required this.repository});

  Future<InventoryItem> call(String inventoryItemId, int newStock, String reason) async {
    return await repository.updateStock(inventoryItemId, newStock, reason);
  }
}
