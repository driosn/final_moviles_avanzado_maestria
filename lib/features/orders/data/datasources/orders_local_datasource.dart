// import 'dart:convert';

// import 'package:drift/drift.dart';

// import '../../../../core/database/app_database.dart';
// import '../../../products/domain/entities/product.dart';
// import '../../domain/entities/order.dart';
// import '../../domain/entities/order_item.dart';

// abstract class OrdersLocalDataSource {
//   Future<List<Order>> getPendingOrders();
//   Future<Order?> getPendingOrderById(String id);
//   Future<void> insertPendingOrder(Order order);
//   Future<void> updatePendingOrderStatus(String id, String status, {String? errorMessage});
//   Future<void> deletePendingOrder(String id);
//   Future<void> clearPendingOrders();
//   Future<int> getPendingOrdersCount();
// }

// class OrdersLocalDataSourceImpl implements OrdersLocalDataSource {
//   final AppDatabase _database;

//   OrdersLocalDataSourceImpl({required AppDatabase database}) : _database = database;

//   @override
//   Future<List<Order>> getPendingOrders() async {
//     try {
//       print('DEBUG: OrdersLocalDataSource.getPendingOrders() called');
//       final pendingOrdersData = await _database.getPendingOrders();
//       print('DEBUG: Found ${pendingOrdersData.length} pending orders in local database');

//       final orders = pendingOrdersData.map((data) => _convertToOrder(data)).toList();
//       print('DEBUG: Converted to ${orders.length} Order entities');
//       return orders;
//     } catch (e) {
//       print('DEBUG: Error in OrdersLocalDataSource.getPendingOrders(): $e');
//       throw Exception('Error al obtener pedidos pendientes locales: ${e.toString()}');
//     }
//   }

//   @override
//   Future<Order?> getPendingOrderById(String id) async {
//     try {
//       final orderData = await _database.getPendingOrderById(id);
//       if (orderData == null) return null;
//       return _convertToOrder(orderData);
//     } catch (e) {
//       throw Exception('Error al obtener pedido pendiente local: ${e.toString()}');
//     }
//   }

//   @override
//   Future<void> insertPendingOrder(Order order) async {
//     try {
//       print('DEBUG: OrdersLocalDataSource.insertPendingOrder() called for order: ${order.id}');
//       print(
//         'DEBUG: Order details - Store: ${order.storeId}, Total: ${order.totalAmount}, Items: ${order.items.length}',
//       );

//       final orderData = _convertToPendingOrderData(order);
//       await _database.insertPendingOrder(orderData);
//       print('DEBUG: Pending order inserted successfully');
//     } catch (e) {
//       print('DEBUG: Error in OrdersLocalDataSource.insertPendingOrder(): $e');
//       throw Exception('Error al insertar pedido pendiente: ${e.toString()}');
//     }
//   }

//   @override
//   Future<void> updatePendingOrderStatus(String id, String status, {String? errorMessage}) async {
//     try {
//       await _database.updatePendingOrderStatus(id, status, errorMessage: errorMessage);
//     } catch (e) {
//       throw Exception('Error al actualizar estado del pedido pendiente: ${e.toString()}');
//     }
//   }

//   @override
//   Future<void> deletePendingOrder(String id) async {
//     try {
//       await _database.deletePendingOrder(id);
//     } catch (e) {
//       throw Exception('Error al eliminar pedido pendiente: ${e.toString()}');
//     }
//   }

//   @override
//   Future<void> clearPendingOrders() async {
//     try {
//       await _database.clearPendingOrders();
//     } catch (e) {
//       throw Exception('Error al limpiar pedidos pendientes: ${e.toString()}');
//     }
//   }

//   @override
//   Future<int> getPendingOrdersCount() async {
//     try {
//       final pendingOrders = await _database.getPendingOrders();
//       return pendingOrders.length;
//     } catch (e) {
//       throw Exception('Error al obtener conteo de pedidos pendientes: ${e.toString()}');
//     }
//   }

//   Order _convertToOrder(PendingOrdersTableData data) {
//     try {
//       // Parse the JSON order data
//       final orderJson = jsonDecode(data.orderData);

//       return Order(
//         id: data.id,
//         userId: data.customerId,
//         storeId: data.storeId,
//         totalAmount: (orderJson['total'] as num).toDouble(),
//         status: _parseOrderStatus(data.status),
//         createdAt: data.createdAt,
//         updatedAt: data.createdAt, // Use createdAt as updatedAt for pending orders
//         items: (orderJson['items'] as List)
//             .map(
//               (item) => OrderItem(
//                 id: '${data.id}_${item['productId']}',
//                 orderId: data.id,
//                 productId: item['productId'],
//                 product: Product(
//                   id: item['productId'],
//                   name: item['productName'],
//                   price: (item['price'] as num).toDouble(),
//                   category: item['category'] ?? 'General',
//                   imageUrl: item['imageUrl'] ?? '',
//                   createdAt: data.createdAt,
//                   updatedAt: data.createdAt,
//                 ),
//                 quantity: item['quantity'],
//                 unitPrice: (item['price'] as num).toDouble(),
//                 totalPrice: (item['price'] as num).toDouble() * item['quantity'],
//                 createdAt: data.createdAt,
//               ),
//             )
//             .toList(),
//       );
//     } catch (e) {
//       print('DEBUG: Error converting pending order data to Order: $e');
//       throw Exception('Error al convertir datos del pedido pendiente: ${e.toString()}');
//     }
//   }

//   PendingOrdersTableCompanion _convertToPendingOrderData(Order order) {
//     try {
//       // Convert order to JSON
//       final orderJson = {
//         'items': order.items
//             .map(
//               (item) => {
//                 'productId': item.productId,
//                 'productName': item.product.name,
//                 'quantity': item.quantity,
//                 'price': item.unitPrice,
//                 'category': item.product.category,
//                 'imageUrl': item.product.imageUrl,
//               },
//             )
//             .toList(),
//         'total': order.totalAmount,
//       };

//       return PendingOrdersTableCompanion(
//         id: Value(order.id),
//         storeId: Value(order.storeId),
//         customerId: Value(order.userId),
//         customerName: Value('Cliente'), // Default name for offline orders
//         customerEmail: Value('cliente@example.com'), // Default email for offline orders
//         orderData: Value(jsonEncode(orderJson)),
//         status: const Value('pending'),
//         createdAt: Value(order.createdAt),
//       );
//     } catch (e) {
//       print('DEBUG: Error converting Order to pending order data: $e');
//       throw Exception('Error al convertir pedido a datos pendientes: ${e.toString()}');
//     }
//   }

//   OrderStatus _parseOrderStatus(String status) {
//     switch (status) {
//       case 'pending':
//         return OrderStatus.pending;
//       case 'syncing':
//         return OrderStatus.pending; // Keep as pending while syncing
//       case 'synced':
//         return OrderStatus.confirmed; // Mark as confirmed when synced
//       case 'failed':
//         return OrderStatus.cancelled;
//       default:
//         return OrderStatus.pending;
//     }
//   }
// }
