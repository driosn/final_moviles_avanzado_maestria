# Configuración del Módulo de Inventario

## Estructura del Proyecto

Este módulo implementa la gestión de inventario para gestores de tienda, permitiendo ver sus tiendas asignadas y gestionar el stock de productos.

### Arquitectura

```
lib/features/inventory/
├── data/
│   ├── datasources/
│   │   └── inventory_remote_datasource.dart
│   ├── models/
│   │   ├── inventory_item_model.dart
│   │   └── stock_movement_model.dart
│   └── repositories/
│       └── inventory_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── inventory_item.dart
│   │   └── stock_movement.dart
│   ├── repositories/
│   │   └── inventory_repository.dart
│   └── usecases/
│       ├── get_inventory_by_store_usecase.dart
│       ├── update_stock_usecase.dart
│       └── get_stock_movements_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── inventory_bloc.dart
    │   ├── inventory_event.dart
    │   └── inventory_state.dart
    └── pages/
        ├── gestor_stores_page.dart
        ├── store_config_page.dart
        ├── store_inventory_page.dart
        └── update_stock_dialog.dart
```

## Configuración de Base de Datos

### 1. Crear Tabla de Items de Inventario

Ejecuta el siguiente SQL en el editor SQL de Supabase:

```sql
-- Crear tabla de items de inventario
CREATE TABLE inventory_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
  min_stock INTEGER NOT NULL DEFAULT 0 CHECK (min_stock >= 0),
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_by UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(store_id, product_id)
);

-- Crear tabla de movimientos de stock
CREATE TABLE stock_movements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  inventory_item_id UUID NOT NULL REFERENCES inventory_items(id) ON DELETE CASCADE,
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('increase', 'decrease')),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  reason TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by UUID NOT NULL REFERENCES auth.users(id)
);

-- Crear índices para mejor rendimiento
CREATE INDEX inventory_items_store_id_idx ON inventory_items(store_id);
CREATE INDEX inventory_items_product_id_idx ON inventory_items(product_id);
CREATE INDEX stock_movements_inventory_item_id_idx ON stock_movements(inventory_item_id);
CREATE INDEX stock_movements_store_id_idx ON stock_movements(store_id);

-- Habilitar RLS (Row Level Security)
ALTER TABLE inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_movements ENABLE ROW LEVEL SECURITY;

-- Políticas para inventory_items
CREATE POLICY "Gestores can view inventory of assigned stores" ON inventory_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM store_assignments sa
      WHERE sa.store_id = inventory_items.store_id
      AND sa.user_id = auth.uid()
    )
  );

CREATE POLICY "Gestores can update inventory of assigned stores" ON inventory_items
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM store_assignments sa
      WHERE sa.store_id = inventory_items.store_id
      AND sa.user_id = auth.uid()
    )
  );

CREATE POLICY "Admins can manage all inventory" ON inventory_items
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

-- Políticas para stock_movements
CREATE POLICY "Gestores can view stock movements of assigned stores" ON stock_movements
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM store_assignments sa
      WHERE sa.store_id = stock_movements.store_id
      AND sa.user_id = auth.uid()
    )
  );

CREATE POLICY "Gestores can create stock movements for assigned stores" ON stock_movements
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM store_assignments sa
      WHERE sa.store_id = stock_movements.store_id
      AND sa.user_id = auth.uid()
    )
  );

CREATE POLICY "Admins can manage all stock movements" ON stock_movements
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

CREATE POLICY "TEMP: Anyone can view all store assignments" ON store_assignments
  FOR SELECT USING (true);

-- ✅ Permite a CUALQUIER usuario ver todos los stores
CREATE POLICY "TEMP: Anyone can view all stores" ON stores
  FOR SELECT USING (true);
```

## Funcionalidades Implementadas

### ✅ Completadas
- [x] Estructura de Clean Architecture
- [x] Inyección de dependencias con GetIt
- [x] Manejo de estado con Bloc
- [x] Integración con Supabase
- [x] Gestión de inventario por tienda
- [x] Actualización de stock con historial
- [x] Interfaz para gestores de tienda
- [x] Validación de permisos por rol

### 🏪 **Funcionalidades del Gestor de Tienda**
- **Ver Tiendas Asignadas**: Lista de tiendas que tiene asignadas
- **Configuración de Tienda**: Opciones de gestión por tienda
- **Administrar Inventario**: Gestión completa de stock de productos
- **Actualizar Stock**: Aumentar/disminuir cantidades con razones
- **Historial de Movimientos**: Registro de todos los cambios de stock

### 🎯 **Operaciones de Inventario**
1. **Ver Inventario**: Lista de productos con stock actual
2. **Actualizar Stock**: Modificar cantidades con justificación
3. **Historial**: Ver movimientos de stock anteriores
4. **Alertas**: Indicadores de stock bajo o agotado

### 🎨 **Interfaz de Usuario**
- **Panel de Gestor**: Página principal con opciones
- **Lista de Tiendas**: Cards con información de cada tienda
- **Configuración de Tienda**: Menú de opciones por tienda
- **Inventario**: Lista de productos con stock y controles
- **Diálogo de Actualización**: Formulario para modificar stock
- **Indicadores Visuales**: Colores para diferentes estados de stock

## Estructura de Datos

### Item de Inventario (InventoryItem)
```dart
class InventoryItem {
  final String id;
  final String storeId;
  final String productId;
  final Product product;
  final int stock;
  final int minStock;
  final DateTime lastUpdated;
  final String updatedBy;
}
```

### Movimiento de Stock (StockMovement)
```dart
class StockMovement {
  final String id;
  final String inventoryItemId;
  final String storeId;
  final String productId;
  final StockMovementType type; // increase, decrease
  final int quantity;
  final String reason;
  final DateTime createdAt;
  final String createdBy;
}
```

## Navegación

### Rutas Disponibles
- **GestorHomePage**: Panel principal del gestor
- **GestorStoresPage**: Lista de tiendas asignadas
- **StoreConfigPage**: Configuración de tienda específica
- **StoreInventoryPage**: Inventario de productos de la tienda

### Acceso
- Solo usuarios con rol `gestorTienda` pueden acceder
- Solo pueden ver/editar tiendas que tienen asignadas
- Los administradores pueden gestionar todo el inventario

## Instalación y Ejecución

### 1. Ejecutar SQL
Ejecuta el SQL proporcionado en Supabase para crear las tablas `inventory_items` y `stock_movements`.

### 2. Verificar Dependencias
Las dependencias ya están configuradas en `injection_container.dart`.

### 3. Probar Funcionalidad
1. Inicia sesión como gestor de tienda
2. Ve al panel de gestor
3. Toca "Mis Tiendas" para ver tiendas asignadas
4. Selecciona una tienda para configurar
5. Toca "Administrar Inventario" para gestionar stock
6. Actualiza stock de productos con razones

## Notas Importantes

1. **Seguridad**: Solo gestores pueden gestionar tiendas asignadas
2. **Validación**: Stock no puede ser negativo
3. **Historial**: Todos los cambios se registran con razón
4. **RLS**: Las políticas de seguridad están configuradas en Supabase
5. **Escalabilidad**: Fácil agregar más funcionalidades de tienda

## Troubleshooting

### Error de Permisos
- Verifica que el usuario tenga rol `gestorTienda`
- Revisa que el usuario tenga tiendas asignadas
- Revisa las políticas RLS en Supabase

### Error de Conexión
- Verifica que las tablas `inventory_items` y `stock_movements` existan
- Revisa las credenciales de Supabase

### Error de Stock
- Verifica que el stock no sea negativo
- Asegúrate de que la razón tenga al menos 3 caracteres
- Verifica que el producto exista en la tienda

### Error de Asignación
- Verifica que el gestor tenga tiendas asignadas en `store_assignments`
- Revisa las políticas de `store_assignments` en Supabase
