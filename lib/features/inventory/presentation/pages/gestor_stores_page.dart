import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/injection/injection_container.dart';
import '../../../users/presentation/bloc/store_assignment_bloc.dart';
import '../../../users/presentation/bloc/store_assignment_event.dart';
import '../../../users/presentation/bloc/store_assignment_state.dart';
import 'store_inventory_page.dart';

class GestorStoresPage extends StatelessWidget {
  const GestorStoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Tiendas'), backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: BlocProvider(
        create: (context) => sl<StoreAssignmentBloc>()..add(const LoadUserAssignedStores()),
        child: BlocConsumer<StoreAssignmentBloc, StoreAssignmentState>(
          listener: (context, state) {
            if (state is StoreAssignmentError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          builder: (context, state) {
            if (state is StoreAssignmentLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserAssignedStoresLoaded) {
              if (state.stores.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No tienes tiendas asignadas', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text(
                        'Contacta al administrador para que te asigne tiendas',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
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
                  return _buildStoreCard(context, store);
                },
              );
            } else if (state is StoreAssignmentError) {
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
                        context.read<StoreAssignmentBloc>().add(const LoadUserAssignedStores());
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

  Widget _buildStoreCard(BuildContext context, dynamic store) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.store, color: Colors.blue, size: 30),
        ),
        title: Text(store.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        // subtitle: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        // children: [
        // const SizedBox(height: 4),
        // Text(store.address, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        // const SizedBox(height: 4),
        // Text(store.phone, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        // ],
        // ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => StoreInventoryPage(store: store)));
        },
      ),
    );
  }
}
