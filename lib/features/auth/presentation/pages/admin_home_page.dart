import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../products/presentation/pages/products_list_page.dart';
import '../../../stores/presentation/pages/stores_list_page.dart';
import '../../../users/presentation/pages/user_management_page.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: Colors.blue,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenido, Administrador',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            const Text('Gestiona tu sistema desde aquí', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 32),

            // Admin Options
            Expanded(
              child: ListView(
                children: [
                  _buildAdminCard(
                    context,
                    icon: Icons.people,
                    title: 'Usuarios',
                    subtitle: 'Gestionar usuarios',
                    color: Colors.green,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UserManagementPage()));
                    },
                  ),
                  _buildAdminCard(
                    context,
                    icon: Icons.store,
                    title: 'Tiendas',
                    subtitle: 'Gestionar tiendas',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const StoresListPage()));
                    },
                  ),
                  _buildAdminCard(
                    context,
                    icon: Icons.inventory,
                    title: 'Productos',
                    subtitle: 'Gestionar productos',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProductsListPage()));
                    },
                  ),
                  _buildAdminCard(
                    context,
                    icon: Icons.analytics,
                    title: 'Reportes',
                    subtitle: 'Ver estadísticas',
                    color: Colors.indigo,
                    onTap: () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Reportes - Próximamente')));
                    },
                  ),
                  _buildAdminCard(
                    context,
                    icon: Icons.settings,
                    title: 'Configuración',
                    subtitle: 'Ajustes del sistema',
                    color: Colors.grey,
                    onTap: () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Configuración - Próximamente')));
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

  Widget _buildAdminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 30, color: color),
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
              Icon(Icons.arrow_forward_ios, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
