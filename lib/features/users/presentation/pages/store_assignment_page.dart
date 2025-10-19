import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/injection/injection_container.dart';
import '../../../stores/domain/entities/store.dart';
import '../../domain/entities/user.dart';
import '../bloc/store_assignment_bloc.dart';
import '../bloc/store_assignment_event.dart';
import '../bloc/store_assignment_state.dart';

class StoreAssignmentPage extends StatefulWidget {
  const StoreAssignmentPage({super.key});

  @override
  State<StoreAssignmentPage> createState() => _StoreAssignmentPageState();
}

class _StoreAssignmentPageState extends State<StoreAssignmentPage> {
  Store? _selectedStore;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignación de Tiendas'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: BlocProvider(
        create: (context) => sl<StoreAssignmentBloc>()..add(const LoadStoresAndUsers()),
        child: BlocConsumer<StoreAssignmentBloc, StoreAssignmentState>(
          listener: (context, state) {
            if (state is StoreAssignmentError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
            } else if (state is UserAssignedToStore) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuario asignado exitosamente'), backgroundColor: Colors.green),
              );
            } else if (state is UserRemovedFromStore) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Usuario removido exitosamente'), backgroundColor: Colors.green),
              );
            }
          },
          builder: (context, state) {
            if (state is StoreAssignmentLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is StoreAssignmentLoaded) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store Selection
                    const Text('Seleccionar Tienda', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Store>(
                      value: _selectedStore,
                      decoration: const InputDecoration(
                        labelText: 'Selecciona una tienda',
                        prefixIcon: Icon(Icons.store),
                        border: OutlineInputBorder(),
                      ),
                      items: state.stores.map((store) {
                        return DropdownMenuItem(
                          value: store,
                          child: Text('${store.name} - ${_getCityDisplayName(store.city)}'),
                        );
                      }).toList(),
                      onChanged: (store) {
                        setState(() {
                          _selectedStore = store;
                        });
                        if (store != null) {
                          context.read<StoreAssignmentBloc>().add(LoadStoreAssignments(store.id));
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Store Assignment Content
                    if (_selectedStore != null) ...[
                      Text(
                        'Gestores asignados a: ${_selectedStore!.name}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Expanded(child: _buildAssignmentContent(context, state, context.read<StoreAssignmentBloc>())),
                    ] else ...[
                      const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.store, size: 80, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Selecciona una tienda para ver las asignaciones',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
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
                        context.read<StoreAssignmentBloc>().add(const LoadStoresAndUsers());
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

  Widget _buildAssignmentContent(BuildContext context, StoreAssignmentLoaded state, StoreAssignmentBloc bloc) {
    final assignedUsers = state.assignedUsers;
    final availableUsers = state.availableUsers;

    return Column(
      children: [
        // Assigned Users Section
        Expanded(
          flex: 1,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Gestores Asignados (${assignedUsers.length})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: assignedUsers.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay gestores asignados a esta tienda',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: assignedUsers.length,
                            itemBuilder: (context, index) {
                              final user = assignedUsers[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green,
                                    child: Text(
                                      user.name?.isNotEmpty == true
                                          ? user.name![0].toUpperCase()
                                          : user.email[0].toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(user.name ?? user.email),
                                  subtitle: Text(user.email),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                                    onPressed: () {
                                      _showRemoveUserDialog(context, user, bloc);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Available Users Section
        Expanded(
          flex: 1,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_add, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Gestores Disponibles (${availableUsers.length})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: availableUsers.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay gestores disponibles para asignar',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: availableUsers.length,
                            itemBuilder: (context, index) {
                              final user = availableUsers[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue,
                                    child: Text(
                                      user.name?.isNotEmpty == true
                                          ? user.name![0].toUpperCase()
                                          : user.email[0].toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  title: Text(user.name ?? user.email),
                                  subtitle: Text(user.email),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.add_circle, color: Colors.green),
                                    onPressed: () {
                                      _showAssignUserDialog(context, user, bloc);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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

  void _showAssignUserDialog(BuildContext context, User user, StoreAssignmentBloc bloc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Asignar Usuario'),
        content: Text('¿Asignar ${user.name ?? user.email} a la tienda ${_selectedStore!.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              bloc.add(AssignUserToStore(userId: user.userId, storeId: _selectedStore!.id));
            },
            child: const Text('Asignar'),
          ),
        ],
      ),
    );
  }

  void _showRemoveUserDialog(BuildContext context, User user, StoreAssignmentBloc bloc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Usuario'),
        content: Text('¿Remover ${user.name ?? user.email} de la tienda ${_selectedStore!.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              bloc.add(RemoveUserFromStore(userId: user.userId, storeId: _selectedStore!.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}
