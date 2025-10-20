// import 'dart:convert';

// import 'package:flutter/material.dart';

// import '../../../../core/network/connectivity_service.dart';
// import '../../../../core/sync/sync_service.dart';

// class PendingOrdersPage extends StatefulWidget {
//   const PendingOrdersPage({super.key});

//   @override
//   State<PendingOrdersPage> createState() => _PendingOrdersPageState();
// }

// class _PendingOrdersPageState extends State<PendingOrdersPage> {
//   final SyncService _syncService = SyncService();
//   final ConnectivityService _connectivityService = ConnectivityService();

//   List<SyncQueueItem> _pendingItems = [];
//   bool _isConnected = false;
//   SyncStatus _syncStatus = SyncStatus.idle;

//   @override
//   void initState() {
//     super.initState();
//     _loadPendingItems();
//     _setupListeners();
//   }

//   void _setupListeners() {
//     _connectivityService.connectionStatusStream.listen((isConnected) {
//       setState(() {
//         _isConnected = isConnected;
//       });
//     });

//     _syncService.syncStatusStream.listen((status) {
//       setState(() {
//         _syncStatus = status;
//       });
//       if (status == SyncStatus.completed) {
//         _loadPendingItems();
//       }
//     });
//   }

//   Future<void> _loadPendingItems() async {
//     final items = await _syncService.getPendingItems();
//     setState(() {
//       _pendingItems = items;
//     });
//   }

//   Future<void> _retrySync() async {
//     if (_isConnected) {
//       await _syncService.syncPendingItems();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Pedidos Pendientes'),
//         backgroundColor: Colors.orange,
//         foregroundColor: Colors.white,
//         actions: [
//           if (_isConnected && _pendingItems.isNotEmpty)
//             IconButton(
//               onPressed: _retrySync,
//               icon: _syncStatus == SyncStatus.syncing
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     )
//                   : const Icon(Icons.sync),
//             ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Connection status banner
//           _buildConnectionStatusBanner(),
//           // Sync status banner
//           if (_syncStatus == SyncStatus.syncing) _buildSyncStatusBanner(),
//           // Pending items list
//           Expanded(child: _buildPendingItemsList()),
//         ],
//       ),
//     );
//   }

//   Widget _buildConnectionStatusBanner() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(12),
//       color: _isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
//       child: Row(
//         children: [
//           Icon(_isConnected ? Icons.wifi : Icons.wifi_off, color: _isConnected ? Colors.green : Colors.red, size: 20),
//           const SizedBox(width: 8),
//           Text(
//             _isConnected ? 'Conectado - Sincronización automática activa' : 'Sin conexión - Modo offline',
//             style: TextStyle(color: _isConnected ? Colors.green : Colors.red, fontWeight: FontWeight.w500),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSyncStatusBanner() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(12),
//       color: Colors.blue.withOpacity(0.1),
//       child: Row(
//         children: [
//           const SizedBox(
//             width: 20,
//             height: 20,
//             child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)),
//           ),
//           const SizedBox(width: 8),
//           const Text(
//             'Sincronizando pedidos...',
//             style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPendingItemsList() {
//     if (_pendingItems.isEmpty) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
//             SizedBox(height: 16),
//             Text('No hay pedidos pendientes', style: TextStyle(fontSize: 18, color: Colors.grey)),
//             SizedBox(height: 8),
//             Text(
//               'Todos los pedidos están sincronizados',
//               style: TextStyle(fontSize: 14, color: Colors.grey),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: _pendingItems.length,
//       itemBuilder: (context, index) {
//         final item = _pendingItems[index];
//         return _buildPendingItemCard(item);
//       },
//     );
//   }

//   Widget _buildPendingItemCard(SyncQueueItem item) {
//     final data = jsonDecode(item.data);
//     final isOrder = item.type == 'order';

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(item.status).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(_getStatusIcon(item.status), color: _getStatusColor(item.status), size: 20),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         isOrder ? 'Pedido' : _getTypeDisplayName(item.type),
//                         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(_formatDate(item.createdAt), style: TextStyle(fontSize: 14, color: Colors.grey[600])),
//                     ],
//                   ),
//                 ),
//                 _buildStatusChip(item.status),
//               ],
//             ),
//             if (isOrder) ...[const SizedBox(height: 12), _buildOrderDetails(data)],
//             if (item.retryCount > 0) ...[
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Icon(Icons.warning_amber, size: 16, color: Colors.orange[600]),
//                   const SizedBox(width: 4),
//                   Text('Reintentos: ${item.retryCount}', style: TextStyle(fontSize: 12, color: Colors.orange[600])),
//                 ],
//               ),
//             ],
//             if (item.errorMessage != null) ...[
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//                 child: Text('Error: ${item.errorMessage}', style: const TextStyle(fontSize: 12, color: Colors.red)),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOrderDetails(Map<String, dynamic> data) {
//     final items = data['items'] as List<dynamic>;
//     final totalAmount = data['total_amount'] as double;

//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '${items.length} producto${items.length != 1 ? 's' : ''}',
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Total: \$${totalAmount.toStringAsFixed(2)}',
//             style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusChip(String status) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: _getStatusColor(status).withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         _getStatusText(status),
//         style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _getStatusColor(status)),
//       ),
//     );
//   }

//   String _getTypeDisplayName(String type) {
//     switch (type) {
//       case 'store':
//         return 'Tienda';
//       case 'product':
//         return 'Producto';
//       case 'order':
//         return 'Pedido';
//       default:
//         return type;
//     }
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'pending':
//         return Colors.orange;
//       case 'syncing':
//         return Colors.blue;
//       case 'completed':
//         return Colors.green;
//       case 'failed':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   IconData _getStatusIcon(String status) {
//     switch (status) {
//       case 'pending':
//         return Icons.pending;
//       case 'syncing':
//         return Icons.sync;
//       case 'completed':
//         return Icons.check_circle;
//       case 'failed':
//         return Icons.error;
//       default:
//         return Icons.help;
//     }
//   }

//   String _getStatusText(String status) {
//     switch (status) {
//       case 'pending':
//         return 'Pendiente';
//       case 'syncing':
//         return 'Sincronizando';
//       case 'completed':
//         return 'Completado';
//       case 'failed':
//         return 'Fallido';
//       default:
//         return status;
//     }
//   }

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);

//     if (difference.inDays == 0) {
//       return 'Hoy a las ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//     } else if (difference.inDays == 1) {
//       return 'Ayer a las ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }
