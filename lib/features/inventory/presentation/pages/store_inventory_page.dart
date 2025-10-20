import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/injection/injection_container.dart';
import '../../domain/entities/inventory_item.dart';
import '../bloc/inventory_bloc.dart';
import '../bloc/inventory_event.dart';
import '../bloc/inventory_state.dart';
import 'update_stock_dialog.dart';

class StoreInventoryPage extends StatefulWidget {
  final dynamic store;

  const StoreInventoryPage({super.key, required this.store});

  @override
  State<StoreInventoryPage> createState() => _StoreInventoryPageState();
}

class _StoreInventoryPageState extends State<StoreInventoryPage> {
  late InventoryBloc inventoryBloc;

  @override
  void initState() {
    super.initState();
    inventoryBloc = sl<InventoryBloc>();
    inventoryBloc.add(LoadAllProductsWithInventory(storeId: widget.store.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: inventoryBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Inventario - ${widget.store.name}'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<InventoryBloc, InventoryState>(
          listener: (context, state) {
            if (state is InventoryError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            } else if (state is StockUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stock actualizado exitosamente'), backgroundColor: Colors.green),
              );
              // Recargar la lista después de actualizar stock
              context.read<InventoryBloc>().add(LoadAllProductsWithInventory(storeId: widget.store.id));
            }
          },
          builder: (context, state) {
            if (state is InventoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AllProductsWithInventoryLoaded) {
              if (state.allProductsWithInventory.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No hay productos disponibles', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.allProductsWithInventory.length,
                itemBuilder: (context, index) {
                  final inventoryItem = state.allProductsWithInventory[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildInventoryItemCard(context, inventoryItem),
                  );
                },
              );
            } else if (state is InventoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 80, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<InventoryBloc>().add(LoadAllProductsWithInventory(storeId: widget.store.id));
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text('Estado no reconocido'));
          },
        ),
      ),
    );
  }

  Widget _buildInventoryItemCard(BuildContext context, InventoryItem inventoryItem) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Imagen del producto
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: inventoryItem.product.imageUrl.isNotEmpty
                    ? DecorationImage(image: NetworkImage(inventoryItem.product.imageUrl), fit: BoxFit.cover)
                    : null,
                color: inventoryItem.product.imageUrl.isEmpty ? Colors.grey[300] : null,
              ),
              child: inventoryItem.product.imageUrl.isEmpty
                  ? const Center(child: Icon(Icons.image, size: 30, color: Colors.grey))
                  : null,
            ),
            const SizedBox(width: 16),

            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inventoryItem.product.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${inventoryItem.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: inventoryItem.product.category == 'Pinturas y Acabados'
                          ? Colors.blue.withOpacity(0.1)
                          : inventoryItem.product.category == 'Pisos y Revestimientos'
                          ? Colors.brown.withOpacity(0.1)
                          : inventoryItem.product.category == 'Iluminación'
                          ? Colors.yellow.withOpacity(0.1)
                          : Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      inventoryItem.product.category,
                      style: TextStyle(
                        fontSize: 10,
                        color: inventoryItem.product.category == 'Pinturas y Acabados'
                            ? Colors.blue
                            : inventoryItem.product.category == 'Pisos y Revestimientos'
                            ? Colors.brown
                            : inventoryItem.product.category == 'Iluminación'
                            ? Colors.orange
                            : Colors.purple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stock y botones
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Indicador de stock
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: inventoryItem.isOutOfStock
                        ? Colors.red.withOpacity(0.1)
                        : inventoryItem.isLowStock
                        ? Colors.orange.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Stock: ${inventoryItem.stock}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: inventoryItem.isOutOfStock
                          ? Colors.red
                          : inventoryItem.isLowStock
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Mín: ${inventoryItem.minStock}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 8),

                // Botón de actualizar stock
                ElevatedButton.icon(
                  onPressed: () {
                    _showUpdateStockDialog(context, inventoryItem);
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Actualizar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStockDialog(BuildContext context, InventoryItem inventoryItem) {
    showDialog(
      context: context,
      builder: (context) => UpdateStockDialog(
        inventoryItem: inventoryItem,
        onStockUpdated: (newStock, reason) {
          inventoryBloc.add(UpdateStock(inventoryItemId: inventoryItem.id, newStock: newStock, reason: reason));
        },
      ),
    );
  }
}
