import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/injection/injection_container.dart';
import '../bloc/stores_bloc.dart';
import '../bloc/stores_event.dart';
import '../bloc/stores_state.dart';
import 'create_store_page.dart';
import 'edit_store_page.dart';

class StoresListPage extends StatelessWidget {
  const StoresListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoresBloc, StoresState>(
      bloc: sl<StoresBloc>(),
      listener: (context, state) {
        if (state is StoreCreated) {
          context.read<StoresBloc>().add(const LoadStores());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestión de Tiendas'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        body: BlocConsumer<StoresBloc, StoresState>(
          listener: (context, state) {
            if (state is StoresError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            } else if (state is StoreCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tienda creada exitosamente'), backgroundColor: Colors.green),
              );
            } else if (state is StoreUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tienda actualizada exitosamente'), backgroundColor: Colors.green),
              );
            } else if (state is StoreDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tienda eliminada exitosamente'), backgroundColor: Colors.green),
              );
            }
          },
          builder: (context, state) {
            if (state is StoresLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is StoresLoaded) {
              if (state.stores.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No hay tiendas registradas', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text(
                        'Toca el botón + para crear una nueva tienda',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.stores.length,
                itemBuilder: (context, index) {
                  final store = state.stores[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Text(
                          store.name[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(store.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_getCityDisplayName(store.city)),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            Navigator.of(
                              context,
                            ).push(MaterialPageRoute(builder: (context) => EditStorePage(store: store)));
                          } else if (value == 'delete') {
                            _showDeleteDialog(context, store);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Eliminar'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is StoresError) {
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
                        context.read<StoresBloc>().add(const LoadStores());
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push<bool?>(MaterialPageRoute(builder: (context) => const CreateStorePage()));
          },
          backgroundColor: Colors.orange,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  String _getCityDisplayName(dynamic city) {
    switch (city.toString()) {
      case 'City.laPaz':
        return 'La Paz';
      case 'City.cochabamba':
        return 'Cochabamba';
      case 'City.santaCruz':
        return 'Santa Cruz';
      default:
        return 'Ciudad no válida';
    }
  }

  void _showDeleteDialog(BuildContext context, dynamic store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Tienda'),
        content: Text('¿Estás seguro de que quieres eliminar la tienda "${store.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<StoresBloc>().add(DeleteStore(store.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
