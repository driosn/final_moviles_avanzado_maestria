import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class GetAllProductsWithInventoryUseCase {
  final InventoryRepository repository;

  GetAllProductsWithInventoryUseCase({required this.repository});

  Future<List<InventoryItem>> call(String storeId) async {
    return await repository.getAllProductsWithInventory(storeId);
  }
}
