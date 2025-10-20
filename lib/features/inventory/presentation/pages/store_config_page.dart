import 'package:flutter/material.dart';

import 'store_inventory_page.dart';

class StoreConfigPage extends StatelessWidget {
  final dynamic store;

  const StoreConfigPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configurar ${store.name}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de la tienda
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.store, color: Colors.blue, size: 25),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(store.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(store.address, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Opciones de configuración
            const Text('Opciones de Configuración', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Administrar Inventario
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory, color: Colors.green, size: 25),
                ),
                title: const Text(
                  'Administrar Inventario',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Gestionar stock de productos',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => StoreInventoryPage(store: store)));
                },
              ),
            ),

            const SizedBox(height: 16),

            // Próximamente - Reportes
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.analytics, color: Colors.orange, size: 25),
                ),
                title: const Text('Reportes de Ventas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                subtitle: const Text('Ver estadísticas de ventas', style: TextStyle(fontSize: 14, color: Colors.grey)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.orange),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reportes - Próximamente'), backgroundColor: Colors.orange),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Próximamente - Configuración
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.settings, color: Colors.purple, size: 25),
                ),
                title: const Text(
                  'Configuración de Tienda',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Ajustes generales de la tienda',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.purple),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configuración - Próximamente'), backgroundColor: Colors.purple),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
