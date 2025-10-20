import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/injection/injection_container.dart';
import '../../../inventory/domain/entities/inventory_item.dart';
import '../../../inventory/presentation/bloc/inventory_bloc.dart';
import '../../../inventory/presentation/bloc/inventory_event.dart';
import '../../../inventory/presentation/bloc/inventory_state.dart';
import 'checkout_page.dart';

class CustomerStoreProductsPage extends StatefulWidget {
  final dynamic store;

  const CustomerStoreProductsPage({super.key, required this.store});

  @override
  State<CustomerStoreProductsPage> createState() => _CustomerStoreProductsPageState();
}

class _CustomerStoreProductsPageState extends State<CustomerStoreProductsPage> {
  final Map<String, int> cart = {};

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<InventoryBloc>()..add(LoadAllProductsWithInventory(storeId: widget.store.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Productos - ${widget.store.name}'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            if (cart.isNotEmpty)
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(store: widget.store, cart: cart),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${cart.values.fold(0, (sum, quantity) => sum + quantity)}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            if (state is InventoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AllProductsWithInventoryLoaded) {
              // Filtrar solo productos con stock > 0
              final availableProducts = state.allProductsWithInventory.where((item) => item.stock > 0).toList();

              if (availableProducts.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No hay productos disponibles en esta tienda',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: availableProducts.length,
                itemBuilder: (context, index) {
                  final inventoryItem = availableProducts[index];
                  return _buildProductCard(context, inventoryItem);
                },
              );
            } else if (state is InventoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar productos: ${state.message}',
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

  Widget _buildProductCard(BuildContext context, InventoryItem inventoryItem) {
    final product = inventoryItem.product;
    final cartQuantity = cart[product.id] ?? 0;
    final availableStock = inventoryItem.stock - cartQuantity;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]),
              child: product.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported, color: Colors.grey, size: 40);
                        },
                      ),
                    )
                  : const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
            ),
            const SizedBox(width: 16),
            // Información del producto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(product.category, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock disponible: $availableStock',
                    style: TextStyle(
                      fontSize: 12,
                      color: availableStock > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Controles del carrito
            Column(
              children: [
                if (cartQuantity > 0) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (cart[product.id]! > 1) {
                              cart[product.id] = cart[product.id]! - 1;
                            } else {
                              cart.remove(product.id);
                            }
                          });
                        },
                        icon: const Icon(Icons.remove),
                        style: IconButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      ),
                      Container(
                        width: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '$cartQuantity',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: availableStock > 0
                            ? () {
                                setState(() {
                                  cart[product.id] = (cart[product.id] ?? 0) + 1;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: availableStock > 0 ? Colors.blue : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: availableStock > 0
                        ? () {
                            setState(() {
                              cart[product.id] = 1;
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: availableStock > 0 ? Colors.blue : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Agregar'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
