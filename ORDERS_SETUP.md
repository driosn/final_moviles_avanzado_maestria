# Configuración del Sistema de Órdenes

## Estructura del Proyecto

Este módulo implementa el sistema de órdenes para clientes, permitiendo realizar compras y gestionar el historial de pedidos.

### Arquitectura

```
lib/features/orders/
├── data/
│   ├── datasources/
│   │   └── orders_remote_datasource.dart
│   ├── models/
│   │   ├── order_model.dart
│   │   └── order_item_model.dart
│   └── repositories/
│       └── orders_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── order.dart
│   │   └── order_item.dart
│   ├── repositories/
│   │   └── orders_repository.dart
│   └── usecases/
│       ├── create_order_usecase.dart
│       ├── get_orders_by_user_usecase.dart
│       └── get_order_by_id_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── orders_bloc.dart
    │   ├── orders_event.dart
    │   └── orders_state.dart
    └── pages/
        ├── orders_list_page.dart
        └── order_detail_page.dart
```

## Configuración de Base de Datos

### 1. Crear Tabla de Órdenes

Ejecuta el siguiente SQL en el editor SQL de Supabase:

```sql
-- Crear tabla de órdenes
CREATE TABLE orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  store_id UUID NOT NULL REFERENCES stores(id) ON DELETE CASCADE,
  total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'cancelled')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla de items de órdenes
CREATE TABLE order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
  total_price DECIMAL(10,2) NOT NULL CHECK (total_price >= 0),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear índices para mejor rendimiento
CREATE INDEX orders_user_id_idx ON orders(user_id);
CREATE INDEX orders_store_id_idx ON orders(store_id);
CREATE INDEX orders_status_idx ON orders(status);
CREATE INDEX order_items_order_id_idx ON order_items(order_id);
CREATE INDEX order_items_product_id_idx ON order_items(product_id);

-- Habilitar RLS (Row Level Security)
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Políticas para orders
CREATE POLICY "Users can view their own orders" ON orders
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can create their own orders" ON orders
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Admins can view all orders" ON orders
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

CREATE POLICY "Gestores can view orders from their stores" ON orders
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM store_assignments sa
      WHERE sa.store_id = orders.store_id
      AND sa.user_id = auth.uid()
    )
  );

-- Políticas para order_items
CREATE POLICY "Users can view order items from their orders" ON order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM orders o
      WHERE o.id = order_items.order_id
      AND o.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create order items for their orders" ON order_items
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM orders o
      WHERE o.id = order_items.order_id
      AND o.user_id = auth.uid()
    )
  );

CREATE POLICY "Admins can view all order items" ON order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_profiles 
      WHERE user_profiles.user_id = auth.uid() 
      AND user_profiles.role = 'admin'
    )
  );

CREATE POLICY "Gestores can view order items from their stores" ON order_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM orders o
      JOIN store_assignments sa ON sa.store_id = o.store_id
      WHERE o.id = order_items.order_id
      AND sa.user_id = auth.uid()
    )
  );

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para actualizar updated_at en orders
CREATE TRIGGER update_orders_updated_at 
    BEFORE UPDATE ON orders 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
```

## Funcionalidades Implementadas

### ✅ Completadas
- [x] Estructura de Clean Architecture
- [x] Inyección de dependencias con GetIt
- [x] Manejo de estado con Bloc
- [x] Integración con Supabase
- [x] Sistema de carrito de compras
- [x] Checkout y confirmación de órdenes
- [x] Actualización automática de stock
- [x] Interfaz para clientes
- [x] Validación de permisos por rol

### 🛒 **Funcionalidades del Cliente**
- **Ver Tiendas**: Lista de todas las tiendas disponibles
- **Explorar Productos**: Productos con stock > 0 por tienda
- **Carrito de Compras**: Agregar/quitar productos
- **Checkout**: Confirmar compra y procesar orden
- **Historial de Pedidos**: Ver órdenes anteriores (próximamente)

### 🎯 **Operaciones de Órdenes**
1. **Crear Orden**: Procesar carrito y crear orden
2. **Actualizar Stock**: Descontar stock de inventory_items
3. **Registrar Items**: Guardar productos y cantidades
4. **Confirmar Compra**: Cambiar estado a 'confirmed'

### 🎨 **Interfaz de Usuario**
- **Lista de Tiendas**: Cards con información de cada tienda
- **Productos de Tienda**: Lista de productos disponibles
- **Carrito Visual**: Indicador de cantidad en AppBar
- **Checkout**: Resumen de compra y confirmación
- **Controles de Cantidad**: Botones +/- para cada producto

## Estructura de Datos

### Orden (Order)
```dart
class Order {
  final String id;
  final String userId;
  final String storeId;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;
}
```

### Item de Orden (OrderItem)
```dart
class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final Product product;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime createdAt;
}
```

## Navegación

### Rutas Disponibles
- **ClienteHomePage**: Panel principal del cliente
- **CustomerStoresPage**: Lista de tiendas disponibles
- **CustomerStoreProductsPage**: Productos de una tienda específica
- **CheckoutPage**: Confirmación de compra

### Flujo de Compra
1. Cliente ve lista de tiendas
2. Selecciona una tienda
3. Ve productos disponibles (stock > 0)
4. Agrega productos al carrito
5. Va a checkout
6. Confirma compra
7. Se actualiza stock y se crea orden

## Instalación y Ejecución

### 1. Ejecutar SQL
Ejecuta el SQL proporcionado en Supabase para crear las tablas `orders` y `order_items`.

### 2. Verificar Dependencias
Las dependencias ya están configuradas en `injection_container.dart`.

### 3. Probar Funcionalidad
1. Inicia sesión como cliente
2. Ve al panel de cliente
3. Toca "Tiendas" para ver tiendas disponibles
4. Selecciona una tienda para ver productos
5. Agrega productos al carrito
6. Toca el ícono del carrito para ir a checkout
7. Confirma la compra

## Notas Importantes

1. **Stock**: Solo se muestran productos con stock > 0
2. **Carrito**: Se mantiene en memoria durante la sesión
3. **Checkout**: Actualiza stock automáticamente al confirmar
4. **RLS**: Las políticas de seguridad están configuradas en Supabase
5. **Validación**: Stock no puede ser negativo
6. **Escalabilidad**: Fácil agregar más funcionalidades de órdenes

## Troubleshooting

### Error de Stock
- Verifica que el producto tenga stock > 0
- Revisa que el gestor haya configurado inventario
- Verifica las políticas RLS de inventory_items

### Error de Permisos
- Verifica que el usuario tenga rol 'cliente'
- Revisa las políticas RLS en Supabase
- Verifica que las tablas existan

### Error de Carrito
- Verifica que el carrito no esté vacío
- Revisa que los productos sigan disponibles
- Verifica que el stock no haya cambiado
