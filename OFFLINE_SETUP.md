# Sistema Offline con Drift

## Descripción General

Este sistema implementa funcionalidad offline completa para el módulo de cliente usando Drift (SQLite) como base de datos local y una cola de sincronización para mantener los datos actualizados cuando hay conexión a internet.

## Arquitectura

### Componentes Principales

1. **Drift Database** - Base de datos local SQLite
2. **Sync Service** - Servicio de sincronización automática
3. **Connectivity Service** - Monitoreo de conectividad
4. **Sync Queue** - Cola de elementos pendientes de sincronización
5. **Pending Orders Page** - Interfaz para ver elementos pendientes

### Flujo de Funcionamiento

```
[Cliente] → [Drift DB] → [Sync Queue] → [Supabase] (cuando hay conexión)
     ↓           ↓            ↓
[Offline]   [Local Data]  [Pending Items]
```

## Configuración

### 1. Dependencias Agregadas

```yaml
dependencies:
  # Offline Database
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.18
  path_provider: ^2.1.2
  path: ^1.8.3
  
  # Connectivity
  connectivity_plus: ^6.0.3

dev_dependencies:
  # Drift Code Generation
  drift_dev: ^2.18.0
  build_runner: ^2.4.8
```

### 2. Generar Código de Drift

Ejecuta el siguiente comando para generar el código de Drift:

```bash
flutter packages pub run build_runner build
```

## Estructura de Base de Datos

### Tablas Principales

#### Stores Table
```sql
CREATE TABLE stores_table (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  phone TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  last_synced_at INTEGER
);
```

#### Products Table
```sql
CREATE TABLE products_table (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  price REAL NOT NULL,
  category TEXT NOT NULL,
  image_url TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  last_synced_at INTEGER
);
```

#### Orders Table
```sql
CREATE TABLE orders_table (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  store_id TEXT NOT NULL,
  total_amount REAL NOT NULL,
  status TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  is_offline INTEGER NOT NULL DEFAULT 0,
  last_synced_at INTEGER
);
```

#### Order Items Table
```sql
CREATE TABLE order_items_table (
  id TEXT PRIMARY KEY,
  order_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price REAL NOT NULL,
  total_price REAL NOT NULL,
  created_at INTEGER NOT NULL
);
```

#### Sync Queue Table
```sql
CREATE TABLE sync_queue_table (
  id TEXT PRIMARY KEY,
  type TEXT NOT NULL,
  action TEXT NOT NULL,
  data TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  created_at INTEGER NOT NULL,
  last_attempt_at INTEGER,
  retry_count INTEGER NOT NULL DEFAULT 0,
  error_message TEXT
);
```

## Servicios

### ConnectivityService

Monitorea el estado de la conexión a internet y notifica cambios.

```dart
class ConnectivityService {
  Stream<bool> get connectionStatusStream;
  bool get isConnected;
  
  Future<void> initialize();
  void dispose();
}
```

### SyncService

Maneja la sincronización automática de datos entre la base de datos local y Supabase.

```dart
class SyncService {
  Stream<SyncStatus> get syncStatusStream;
  
  Future<void> initialize();
  Future<void> addToSyncQueue({
    required String type,
    required String action,
    required Map<String, dynamic> data,
  });
  Future<List<SyncQueueItem>> getPendingItems();
  void dispose();
}
```

## Funcionalidades Offline

### 1. Almacenamiento Local

- **Tiendas**: Se almacenan localmente para acceso offline
- **Productos**: Se sincronizan y almacenan localmente
- **Pedidos**: Se crean localmente y se sincronizan cuando hay conexión

### 2. Cola de Sincronización

- **Pedidos**: Se agregan a la cola cuando se crean offline
- **Reintentos**: Sistema de reintentos automáticos (máximo 3)
- **Estados**: pending, syncing, completed, failed

### 3. Sincronización Automática

- **Detección de conexión**: Se activa automáticamente cuando hay internet
- **Sincronización periódica**: Cada 5 minutos cuando hay conexión
- **Sincronización manual**: Botón de sincronización en la UI

## Interfaz de Usuario

### Página de Pedidos Pendientes

- **Estado de conexión**: Banner que muestra si hay conexión
- **Estado de sincronización**: Indicador de sincronización en progreso
- **Lista de elementos pendientes**: Cards con información detallada
- **Reintentos**: Información sobre reintentos fallidos
- **Errores**: Mensajes de error detallados

### Navegación

- **ClienteHomePage**: Nueva opción "Pedidos Pendientes"
- **Acceso directo**: Desde el menú principal del cliente

## Estados de Sincronización

### SyncStatus Enum

```dart
enum SyncStatus {
  idle,      // Sin sincronización activa
  syncing,   // Sincronizando en progreso
  completed, // Sincronización completada
  failed,    // Sincronización fallida
}
```

### Estados de Elementos en Cola

- **pending**: Esperando sincronización
- **syncing**: Sincronizando actualmente
- **completed**: Sincronizado exitosamente
- **failed**: Falló después de múltiples reintentos

## Flujo de Sincronización

### 1. Creación de Pedido Offline

```dart
// 1. Crear pedido en base de datos local
final order = await _database.insertOrder(orderData);

// 2. Agregar a cola de sincronización
await _syncService.addToSyncQueue(
  type: 'order',
  action: 'create',
  data: orderData,
);
```

### 2. Sincronización Automática

```dart
// 1. Detectar conexión
if (_connectivityService.isConnected) {
  // 2. Obtener elementos pendientes
  final pendingItems = await _database.getPendingSyncItems();
  
  // 3. Sincronizar cada elemento
  for (final item in pendingItems) {
    await _syncItem(item);
  }
}
```

### 3. Manejo de Errores

```dart
// 1. Incrementar contador de reintentos
final newRetryCount = item.retryCount + 1;

// 2. Verificar límite de reintentos
if (newRetryCount >= maxRetries) {
  await _database.updateSyncItemStatus(item.id, 'failed');
} else {
  await _database.updateSyncItemStatus(item.id, 'pending');
}
```

## Beneficios

### 1. Experiencia de Usuario

- **Funcionalidad offline**: Los clientes pueden usar la app sin internet
- **Sincronización transparente**: Los datos se sincronizan automáticamente
- **Feedback visual**: Indicadores claros del estado de sincronización

### 2. Confiabilidad

- **Datos persistentes**: Los datos se almacenan localmente
- **Reintentos automáticos**: Sistema robusto de reintentos
- **Manejo de errores**: Gestión completa de errores de sincronización

### 3. Escalabilidad

- **Arquitectura modular**: Fácil agregar nuevos tipos de datos
- **Base de datos eficiente**: SQLite para rendimiento óptimo
- **Sincronización inteligente**: Solo sincroniza cuando es necesario

## Instalación y Configuración

### 1. Instalar Dependencias

```bash
flutter pub get
```

### 2. Generar Código de Drift

```bash
flutter packages pub run build_runner build
```

### 3. Inicializar Servicios

```dart
// En main.dart
await ConnectivityService().initialize();
await SyncService().initialize();
```

### 4. Configurar Base de Datos

```dart
// En injection_container.dart
sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
```

## Troubleshooting

### Problemas Comunes

1. **Error de generación de código**: Ejecutar `flutter packages pub run build_runner build --delete-conflicting-outputs`
2. **Base de datos no se crea**: Verificar permisos de escritura
3. **Sincronización no funciona**: Verificar conectividad y credenciales de Supabase

### Logs de Debug

El sistema incluye logs detallados para debugging:
- Estado de conectividad
- Elementos en cola de sincronización
- Errores de sincronización
- Reintentos y fallos

## Próximos Pasos

1. **Implementar repositorios offline** para stores y products
2. **Integrar lógica offline** en BLoCs existentes
3. **Agregar sincronización bidireccional** para updates
4. **Implementar conflict resolution** para datos concurrentes
5. **Agregar métricas de sincronización** para monitoreo
