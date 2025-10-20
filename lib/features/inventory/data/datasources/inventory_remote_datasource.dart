import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/stock_movement.dart';
import '../models/inventory_item_model.dart';
import '../models/stock_movement_model.dart';

abstract class InventoryRemoteDataSource {
  Future<List<InventoryItem>> getInventoryByStore(String storeId);
  Future<List<InventoryItem>> getAllProductsWithInventory(String storeId);
  Future<InventoryItem> getInventoryItem(String inventoryItemId);
  Future<InventoryItem> updateStock(String inventoryItemId, int newStock, String reason);
  Future<List<StockMovement>> getStockMovements(String inventoryItemId);
  Future<InventoryItem> createInventoryItem(InventoryItem inventoryItem);
}

class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final supabase.SupabaseClient _supabaseClient;

  InventoryRemoteDataSourceImpl({required supabase.SupabaseClient supabaseClient}) : _supabaseClient = supabaseClient;

  @override
  Future<List<InventoryItem>> getInventoryByStore(String storeId) async {
    try {
      final response = await _supabaseClient
          .from('inventory_items')
          .select('''
            *,
            products (*)
          ''')
          .eq('store_id', storeId)
          .order('last_updated', ascending: false);

      return response.map((json) => InventoryItemModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw Exception('Error al cargar inventario: $e');
    }
  }

  @override
  Future<List<InventoryItem>> getAllProductsWithInventory(String storeId) async {
    try {
      print('DEBUG: Loading all products with inventory for store: $storeId');

      // Obtener todos los productos
      final productsResponse = await _supabaseClient.from('products').select('*').order('name');
      print('DEBUG: Found ${productsResponse.length} products');

      if (productsResponse.isEmpty) {
        throw Exception('No hay productos en la base de datos. Por favor, crea algunos productos primero.');
      }

      // Obtener inventario existente para esta tienda específica
      final inventoryResponse = await _supabaseClient.from('inventory_items').select('*').eq('store_id', storeId);
      print('DEBUG: Found ${inventoryResponse.length} inventory items for store $storeId');

      // Crear un mapa del inventario existente por product_id
      final inventoryMap = <String, Map<String, dynamic>>{};
      for (final item in inventoryResponse) {
        inventoryMap[item['product_id']] = item;
      }

      // Crear InventoryItems para todos los productos
      final List<InventoryItem> allProductsWithInventory = [];

      for (final product in productsResponse) {
        final productId = product['id'];
        final existingInventory = inventoryMap[productId];

        print('DEBUG: Processing product: ${product['name']} (ID: $productId)');

        if (existingInventory != null) {
          // Producto ya tiene inventario en esta tienda, usar datos reales
          print('DEBUG: Product has existing inventory in store: ${existingInventory['stock']}');
          final inventoryItem = InventoryItemModel.fromJson({...existingInventory, 'products': product}).toEntity();
          allProductsWithInventory.add(inventoryItem);
        } else {
          // Producto no tiene inventario en esta tienda, crear con stock 0
          print('DEBUG: Product has no inventory in this store, creating with stock 0');
          final newInventoryItem = InventoryItemModel.fromJson({
            'id': 'temp_${productId}_$storeId',
            'product_id': productId,
            'store_id': storeId,
            'stock': 0, // Stock 0 para productos sin inventario en esta tienda
            'last_updated': DateTime.now().toIso8601String(),
            'products': product,
          }).toEntity();
          allProductsWithInventory.add(newInventoryItem);
        }
      }

      print('DEBUG: Returning ${allProductsWithInventory.length} products with inventory for store $storeId');
      return allProductsWithInventory;
    } catch (e) {
      print('DEBUG: Error in getAllProductsWithInventory: $e');
      throw Exception('Error al cargar productos con inventario: $e');
    }
  }

  @override
  Future<InventoryItem> getInventoryItem(String inventoryItemId) async {
    try {
      final response = await _supabaseClient
          .from('inventory_items')
          .select('''
            *,
            products (*)
          ''')
          .eq('id', inventoryItemId)
          .single();

      return InventoryItemModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al cargar item de inventario: $e');
    }
  }

  @override
  Future<InventoryItem> updateStock(String inventoryItemId, int newStock, String reason) async {
    try {
      print('DEBUG: Updating stock for inventory item: $inventoryItemId to $newStock');

      // Verificar si es un ID temporal (empieza con 'temp_')
      if (inventoryItemId.startsWith('temp_')) {
        // Es un ID temporal, necesitamos crear un nuevo inventory_item
        print('DEBUG: Creating new inventory item for temporary ID: $inventoryItemId');

        // Extraer product_id y store_id del ID temporal
        final parts = inventoryItemId.split('_');
        if (parts.length < 3) {
          throw Exception('ID temporal inválido: $inventoryItemId');
        }

        final productId = parts[1];
        final storeId = parts[2];

        // Crear nuevo inventory_item
        final response = await _supabaseClient
            .from('inventory_items')
            .insert({
              'product_id': productId,
              'store_id': storeId,
              'stock': newStock,
              'last_updated': DateTime.now().toIso8601String(),
              'updated_by': _supabaseClient.auth.currentUser?.id ?? '',
            })
            .select('''
                *,
                products (*)
              ''')
            .single();

        // Crear movimiento de stock inicial
        if (newStock > 0) {
          await _supabaseClient.from('stock_movements').insert({
            'inventory_item_id': response['id'],
            'store_id': storeId,
            'product_id': productId,
            'type': 'increase',
            'quantity': newStock,
            'reason': reason,
            'created_by': _supabaseClient.auth.currentUser?.id ?? '',
          });
        }

        print('DEBUG: Created new inventory item with ID: ${response['id']}');
        return InventoryItemModel.fromJson(response).toEntity();
      } else {
        // Es un ID real, actualizar el inventory_item existente
        print('DEBUG: Updating existing inventory item: $inventoryItemId');

        // Obtener el item actual
        final currentItem = await getInventoryItem(inventoryItemId);
        final oldStock = currentItem.stock;
        final stockDifference = newStock - oldStock;

        // Actualizar el stock
        final response = await _supabaseClient
            .from('inventory_items')
            .update({'stock': newStock, 'last_updated': DateTime.now().toIso8601String()})
            .eq('id', inventoryItemId)
            .select('''
                *,
                products (*)
              ''')
            .single();

        // Crear movimiento de stock si hay cambio
        if (stockDifference != 0) {
          await _supabaseClient.from('stock_movements').insert({
            'inventory_item_id': inventoryItemId,
            'store_id': currentItem.storeId,
            'product_id': currentItem.productId,
            'type': stockDifference > 0 ? 'increase' : 'decrease',
            'quantity': stockDifference.abs(),
            'reason': reason,
            'created_by': _supabaseClient.auth.currentUser?.id ?? '',
          });
        }

        print('DEBUG: Updated existing inventory item');
        return InventoryItemModel.fromJson(response).toEntity();
      }
    } catch (e) {
      print('DEBUG: Error updating stock: $e');
      throw Exception('Error al actualizar stock: $e');
    }
  }

  @override
  Future<List<StockMovement>> getStockMovements(String inventoryItemId) async {
    try {
      final response = await _supabaseClient
          .from('stock_movements')
          .select('*')
          .eq('inventory_item_id', inventoryItemId)
          .order('created_at', ascending: false);

      return response.map((json) => StockMovementModel.fromJson(json).toEntity()).toList();
    } catch (e) {
      throw Exception('Error al cargar movimientos de stock: $e');
    }
  }

  @override
  Future<InventoryItem> createInventoryItem(InventoryItem inventoryItem) async {
    try {
      final inventoryItemModel = InventoryItemModel.fromEntity(inventoryItem);
      final response = await _supabaseClient.from('inventory_items').insert(inventoryItemModel.toSupabaseJson()).select(
        '''
            *,
            products (*)
          ''',
      ).single();

      return InventoryItemModel.fromJson(response).toEntity();
    } catch (e) {
      throw Exception('Error al crear item de inventario: $e');
    }
  }
}
