import 'package:final_movil_aplicaciones_avanzado/features/orders/presentation/pages/orders_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../stores/presentation/pages/customer_stores_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class ClienteHomePage extends StatelessWidget {
  const ClienteHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cliente'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.person, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              '¡Bienvenido, Cliente!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Opciones disponibles
            Expanded(
              child: ListView(
                children: [
                  _buildCustomerCard(
                    context,
                    icon: Icons.store,
                    title: 'Tiendas',
                    subtitle: 'Explora y compra en nuestras tiendas',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerStoresPage()));
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildCustomerCard(
                    context,
                    icon: Icons.history,
                    title: 'Mis Pedidos',
                    subtitle: 'Ver historial de compras',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersListPage()));
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildCustomerCard(
                    context,
                    icon: Icons.person_outline,
                    title: 'Mi Perfil',
                    subtitle: 'Próximamente - Gestiona tu perfil',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funcionalidad próximamente disponible'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.green, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
