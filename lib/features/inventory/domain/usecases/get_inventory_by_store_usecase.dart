import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class GetInventoryByStoreUseCase {
  final InventoryRepository repository;

  GetInventoryByStoreUseCase({required this.repository});

  Future<List<InventoryItem>> call(String storeId) async {
    return await repository.getInventoryByStore(storeId);
  }
}
