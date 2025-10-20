import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order_model.dart';

abstract class OrdersRemoteDataSource {
  Future<OrderModel> createOrder({
    required String storeId,
    required Map<String, int> cart,
    required List<dynamic> inventoryItems,
  });

  Future<List<OrderModel>> getOrdersByUser();

  Future<OrderModel> getOrderById(String orderId);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final SupabaseClient _supabaseClient;

  OrdersRemoteDataSourceImpl(this._supabaseClient);

  @override
  Future<OrderModel> createOrder({
    required String storeId,
    required Map<String, int> cart,
    required List<dynamic> inventoryItems,
  }) async {
    try {
      print('DEBUG: Creating order for store: $storeId');
      print('DEBUG: Cart items: $cart');

      final currentUserId = _supabaseClient.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('Usuario no autenticado');
      }

      // Calcular total
      double totalAmount = 0.0;
      for (final entry in cart.entries) {
        final inventoryItem = inventoryItems.firstWhere((item) => item.product.id == entry.key);
        totalAmount += inventoryItem.product.price * entry.value;
      }

      print('DEBUG: Total amount: $totalAmount');

      // Crear la orden
      final orderResponse = await _supabaseClient
          .from('orders')
          .insert({'user_id': currentUserId, 'store_id': storeId, 'total_amount': totalAmount, 'status': 'confirmed'})
          .select()
          .single();

      print('DEBUG: Order created with ID: ${orderResponse['id']}');

      // Crear los items de la orden
      final List<Map<String, dynamic>> orderItemsData = [];
      for (final entry in cart.entries) {
        final inventoryItem = inventoryItems.firstWhere((item) => item.product.id == entry.key);

        orderItemsData.add({
          'order_id': orderResponse['id'],
          'product_id': entry.key,
          'quantity': entry.value,
          'unit_price': inventoryItem.product.price,
          'total_price': inventoryItem.product.price * entry.value,
        });
      }

      // Insertar todos los items de la orden
      final orderItemsResponse = await _supabaseClient.from('order_items').insert(orderItemsData).select('''
            *,
            products (*)
          ''');

      print('DEBUG: Created ${orderItemsResponse.length} order items');

      // Actualizar stock en inventory_items
      for (final entry in cart.entries) {
        final inventoryItem = inventoryItems.firstWhere((item) => item.product.id == entry.key);

        final newStock = inventoryItem.stock - entry.value;
        print('DEBUG: Updating stock for product ${entry.key} from ${inventoryItem.stock} to $newStock');

        if (inventoryItem.id.startsWith('temp_')) {
          // Crear nuevo inventory_item si es temporal
          await _supabaseClient.from('inventory_items').insert({
            'product_id': entry.key,
            'store_id': storeId,
            'stock': newStock,
            'last_updated': DateTime.now().toIso8601String(),
            'updated_by': currentUserId,
          });
        } else {
          // Actualizar inventory_item existente
          await _supabaseClient
              .from('inventory_items')
              .update({'stock': newStock, 'last_updated': DateTime.now().toIso8601String()})
              .eq('id', inventoryItem.id);
        }

        // Crear movimiento de stock
        await _supabaseClient.from('stock_movements').insert({
          'inventory_item_id': inventoryItem.id.startsWith('temp_') ? null : inventoryItem.id,
          'store_id': storeId,
          'product_id': entry.key,
          'type': 'decrease',
          'quantity': entry.value,
          'reason': 'Venta - Orden ${orderResponse['id']}',
          'created_by': currentUserId,
        });
      }

      print('DEBUG: Stock updated successfully');

      // Obtener la orden completa con items
      final completeOrderResponse = await _supabaseClient
          .from('orders')
          .select('''
            *,
            order_items (
              *,
              products (*)
            )
          ''')
          .eq('id', orderResponse['id'])
          .single();

      print('DEBUG: Order creation completed successfully');
      return OrderModel.fromJson(completeOrderResponse);
    } catch (e) {
      print('DEBUG: Error creating order: $e');
      throw Exception('Error al crear la orden: $e');
    }
  }

  @override
  Future<List<OrderModel>> getOrdersByUser() async {
    try {
      final currentUserId = _supabaseClient.auth.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('Usuario no autenticado');
      }

      final response = await _supabaseClient
          .from('orders')
          .select('''
            *,
            order_items (
              *,
              products (*)
            ),
            stores (*)
          ''')
          .eq('user_id', currentUserId)
          .order('created_at', ascending: false);

      return response.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener órdenes: $e');
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      final response = await _supabaseClient
          .from('orders')
          .select('''
            *,
            order_items (
              *,
              products (*)
            ),
            stores (*)
          ''')
          .eq('id', orderId)
          .single();

      return OrderModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener orden: $e');
    }
  }
}
