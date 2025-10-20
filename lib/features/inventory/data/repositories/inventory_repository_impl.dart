import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_datasource.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<InventoryItem>> getInventoryByStore(String storeId) async {
    return await remoteDataSource.getInventoryByStore(storeId);
  }

  @override
  Future<List<InventoryItem>> getAllProductsWithInventory(String storeId) async {
    return await remoteDataSource.getAllProductsWithInventory(storeId);
  }

  @override
  Future<InventoryItem> getInventoryItem(String inventoryItemId) async {
    return await remoteDataSource.getInventoryItem(inventoryItemId);
  }

  @override
  Future<InventoryItem> updateStock(String inventoryItemId, int newStock, String reason) async {
    return await remoteDataSource.updateStock(inventoryItemId, newStock, reason);
  }

  @override
  Future<List<StockMovement>> getStockMovements(String inventoryItemId) async {
    return await remoteDataSource.getStockMovements(inventoryItemId);
  }

  @override
  Future<InventoryItem> createInventoryItem(InventoryItem inventoryItem) async {
    return await remoteDataSource.createInventoryItem(inventoryItem);
  }
}
