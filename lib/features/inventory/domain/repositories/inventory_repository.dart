import '../entities/inventory_item.dart';
import '../entities/stock_movement.dart';

abstract class InventoryRepository {
  Future<List<InventoryItem>> getInventoryByStore(String storeId);
  Future<List<InventoryItem>> getAllProductsWithInventory(String storeId);
  Future<InventoryItem> getInventoryItem(String inventoryItemId);
  Future<InventoryItem> updateStock(String inventoryItemId, int newStock, String reason);
  Future<List<StockMovement>> getStockMovements(String inventoryItemId);
  Future<InventoryItem> createInventoryItem(InventoryItem inventoryItem);
}
