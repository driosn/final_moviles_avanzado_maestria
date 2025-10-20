// import 'dart:async';

// import '../../domain/entities/order.dart';
// import '../datasources/orders_local_datasource.dart';
// import '../datasources/orders_remote_datasource.dart';

// class OrdersSyncService {
//   static final OrdersSyncService _instance = OrdersSyncService._internal();
//   factory OrdersSyncService() => _instance;
//   OrdersSyncService._internal();

//   final ConnectivityService _connectivityService = ConnectivityService();
//   final StreamController<OrdersSyncStatus> _syncStatusController = StreamController<OrdersSyncStatus>.broadcast();

//   Stream<OrdersSyncStatus> get syncStatusStream => _syncStatusController.stream;

//   bool _isSyncing = false;
//   OrdersLocalDataSource? _localDataSource;
//   OrdersRemoteDataSource? _remoteDataSource;

//   void initialize({required OrdersLocalDataSource localDataSource, required OrdersRemoteDataSource remoteDataSource}) {
//     _localDataSource = localDataSource;
//     _remoteDataSource = remoteDataSource;
//   }

//   Future<void> syncPendingOrders() async {
//     if (_isSyncing || _localDataSource == null || _remoteDataSource == null) {
//       print(
//         'DEBUG: OrdersSyncService.syncPendingOrders() - Cannot sync: isSyncing=$_isSyncing, localDataSource=${_localDataSource != null}, remoteDataSource=${_remoteDataSource != null}',
//       );
//       return;
//     }

//     if (!_connectivityService.isConnected) {
//       print('DEBUG: OrdersSyncService.syncPendingOrders() - No internet connection');
//       _syncStatusController.add(OrdersSyncStatus.noConnection);
//       return;
//     }

//     _isSyncing = true;
//     _syncStatusController.add(OrdersSyncStatus.syncing);

//     try {
//       print('DEBUG: OrdersSyncService.syncPendingOrders() - Starting sync');

//       // Get all pending orders
//       final pendingOrders = await _localDataSource!.getPendingOrders();
//       print('DEBUG: Found ${pendingOrders.length} pending orders to sync');

//       if (pendingOrders.isEmpty) {
//         print('DEBUG: No pending orders to sync');
//         _syncStatusController.add(OrdersSyncStatus.completed);
//         return;
//       }

//       int successCount = 0;
//       int failureCount = 0;

//       for (final order in pendingOrders) {
//         try {
//           print('DEBUG: Syncing order ${order.id}');

//           // Update status to syncing
//           await _localDataSource!.updatePendingOrderStatus(order.id, 'syncing');

//           // Convert order to the format expected by remote data source
//           final cart = <String, int>{};
//           final inventoryItems = <dynamic>[];

//           for (final item in order.items) {
//             cart[item.productId] = item.quantity;
//             inventoryItems.add({
//               'product': item.product,
//               'stock': 0, // Default stock for offline orders
//             });
//           }

//           // Send to remote server
//           await _remoteDataSource!.createOrder(storeId: order.storeId, cart: cart, inventoryItems: inventoryItems);
//           print('DEBUG: Order ${order.id} synced successfully');

//           // Update status to synced and remove from local queue
//           await _localDataSource!.updatePendingOrderStatus(order.id, 'synced');
//           await _localDataSource!.deletePendingOrder(order.id);

//           successCount++;
//         } catch (e) {
//           print('DEBUG: Failed to sync order ${order.id}: $e');

//           // Update status to failed
//           await _localDataSource!.updatePendingOrderStatus(order.id, 'failed', errorMessage: e.toString());

//           failureCount++;
//         }
//       }

//       print('DEBUG: Sync completed - Success: $successCount, Failures: $failureCount');

//       if (failureCount == 0) {
//         _syncStatusController.add(OrdersSyncStatus.completed);
//       } else if (successCount == 0) {
//         _syncStatusController.add(OrdersSyncStatus.failed);
//       } else {
//         _syncStatusController.add(OrdersSyncStatus.partialSuccess);
//       }
//     } catch (e) {
//       print('DEBUG: Error during orders sync: $e');
//       _syncStatusController.add(OrdersSyncStatus.failed);
//     } finally {
//       _isSyncing = false;
//     }
//   }

//   Future<int> getPendingOrdersCount() async {
//     if (_localDataSource == null) return 0;
//     try {
//       return await _localDataSource!.getPendingOrdersCount();
//     } catch (e) {
//       print('DEBUG: Error getting pending orders count: $e');
//       return 0;
//     }
//   }

//   Future<List<Order>> getPendingOrders() async {
//     if (_localDataSource == null) return [];
//     try {
//       return await _localDataSource!.getPendingOrders();
//     } catch (e) {
//       print('DEBUG: Error getting pending orders: $e');
//       return [];
//     }
//   }

//   void dispose() {
//     _syncStatusController.close();
//   }
// }

// enum OrdersSyncStatus { idle, syncing, completed, failed, partialSuccess, noConnection }
